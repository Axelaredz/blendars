// Server-side Lobby System for Nakama
// This Go module handles lobby creation, management, and matchmaking

// @title Lobby System API
// @version 1.0
// @description System for managing game lobbies and matchmaking

package modules

import (
	"context"
	"database/sql"
	"encoding/json"
	"fmt"
	"log"
	"time"

	"github.com/heroiclabs/nakama-common/runtime"
)

// Lobby represents a game lobby
type Lobby struct {
	ID             string                 `json:"id"`
	Name           string                 `json:"name"`
	MaxPlayers     int                    `json:"max_players"`
	CurrentPlayers int                    `json:"current_players"`
	IsPrivate      bool                   `json:"is_private"`
	CustomProps    map[string]interface{} `json:"custom_properties"`
	CreatedBy      string                 `json:"created_by"`
	CreatedAt      time.Time              `json:"created_at"`
	LastActivity   time.Time              `json:"last_activity"`
}

// LobbyPlayer represents a player in a lobby
type LobbyPlayer struct {
	UserID   string `json:"user_id"`
	Username string `json:"username"`
	Ready    bool   `json:"ready"`
	Team     string `json:"team,omitempty"`
}

// LobbyManager manages all active lobbies
type LobbyManager struct {
	lobbies map[string]*Lobby
	players map[string][]*LobbyPlayer // lobby_id -> players
	ctx     context.Context
	logger  runtime.Logger
	db      *sql.DB
 nk      runtime.NakamaModule
}

// Global lobby manager instance
var lobbyManager *LobbyManager

// InitLobbySystem initializes the lobby system
func InitLobbySystem(ctx context.Context, logger runtime.Logger, db *sql.DB, nk runtime.NakamaModule) error {
	lobbyManager = &LobbyManager{
		lobbies: make(map[string]*Lobby),
		players: make(map[string][]*LobbyPlayer),
		ctx:     ctx,
		logger:  logger,
		db:      db,
		nk:      nk,
	}

	// Register RPC endpoints
	if err := nk.RegisterRpc("create_lobby", createLobby); err != nil {
		return fmt.Errorf("failed to register create_lobby RPC: %v", err)
	}
	if err := nk.RegisterRpc("join_lobby", joinLobby); err != nil {
		return fmt.Errorf("failed to register join_lobby RPC: %v", err)
	}
	if err := nk.RegisterRpc("join_lobby_by_code", joinLobbyByCode); err != nil {
		return fmt.Errorf("failed to register join_lobby_by_code RPC: %v", err)
	}
	if err := nk.RegisterRpc("leave_lobby", leaveLobby); err != nil {
		return fmt.Errorf("failed to register leave_lobby RPC: %v", err)
	}
	if err := nk.RegisterRpc("search_lobbies", searchLobbies); err != nil {
		return fmt.Errorf("failed to register search_lobbies RPC: %v", err)
	}
	if err := nk.RegisterRpc("get_lobby_info", getLobbyInfo); err != nil {
		return fmt.Errorf("failed to register get_lobby_info RPC: %v", err)
	}
	if err := nk.RegisterRpc("send_lobby_invite", sendLobbyInvite); err != nil {
		return fmt.Errorf("failed to register send_lobby_invite RPC: %v", err)
	}
	if err := nk.RegisterRpc("start_game", startGame); err != nil {
		return fmt.Errorf("failed to register start_game RPC: %v", err)
	}

	logger.Info("Lobby system initialized successfully")
	return nil
}

// createLobby creates a new game lobby
func createLobby(ctx context.Context, logger runtime.Logger, db *sql.DB, nk runtime.NakamaModule, payload string) (string, error) {
	userID, ok := ctx.Value(runtime.RUNTIME_CTX_USER_ID).(string)
	if !ok {
		return "", fmt.Errorf("user ID not found in context")
	}

	username, ok := ctx.Value(runtime.RUNTIME_CTX_USERNAME).(string)
	if !ok {
		return "", fmt.Errorf("username not found in context")
	}

	var req struct {
		Name           string                 `json:"name"`
		MaxPlayers     int                    `json:"max_players"`
		IsPrivate      bool                   `json:"is_private"`
		CustomProperties map[string]interface{} `json:"custom_properties"`
	}
	
	if err := json.Unmarshal([]byte(payload), &req); err != nil {
		return "", fmt.Errorf("invalid payload: %v", err)
	}

	// Validate input
	if req.Name == "" {
		return "", fmt.Errorf("lobby name is required")
	}
	if req.MaxPlayers <= 0 || req.MaxPlayers > 16 { // Max 16 players per lobby
		return "", fmt.Errorf("invalid max players: must be between 1 and 16")
	}

	// Generate unique lobby ID
	lobbyID := generateLobbyID()
	
	// Create lobby object
	lobby := &Lobby{
		ID:             lobbyID,
		Name:           req.Name,
		MaxPlayers:     req.MaxPlayers,
		CurrentPlayers: 1, // Creator joins automatically
		IsPrivate:      req.IsPrivate,
		CustomProps:    req.CustomProperties,
		CreatedBy:      userID,
		CreatedAt:      time.Now(),
		LastActivity:   time.Now(),
	}

	// Add creator as first player
	player := &LobbyPlayer{
		UserID:   userID,
		Username: username,
		Ready:    false,
	}
	
	// Store lobby and player
	lobbyManager.lobbies[lobbyID] = lobby
	lobbyManager.players[lobbyID] = []*LobbyPlayer{player}

	// Prepare response
	response := map[string]interface{}{
		"lobby_id":     lobby.ID,
		"name":         lobby.Name,
		"max_players":  lobby.MaxPlayers,
		"current_players": lobby.CurrentPlayers,
		"is_private":   lobby.IsPrivate,
		"custom_properties": lobby.CustomProps,
		"created_by":   lobby.CreatedBy,
		"players": []map[string]interface{}{
			{
				"user_id": userID,
				"username": username,
				"ready": false,
			},
		},
	}

	// Notify other players in lobby via stream
	go notifyLobbyUpdate(lobbyID)

	logger.Info(fmt.Sprintf("Created lobby %s for user %s", lobbyID, userID))
	
	jsonResp, err := json.Marshal(response)
	if err != nil {
		return "", fmt.Errorf("failed to marshal response: %v", err)
	}

	return string(jsonResp), nil
}

// joinLobby allows a player to join an existing lobby
func joinLobby(ctx context.Context, logger runtime.Logger, db *sql.DB, nk runtime.NakamaModule, payload string) (string, error) {
	userID, ok := ctx.Value(runtime.RUNTIME_CTX_USER_ID).(string)
	if !ok {
		return "", fmt.Errorf("user ID not found in context")
	}

	username, ok := ctx.Value(runtime.RUNTIME_CTX_USERNAME).(string)
	if !ok {
		return "", fmt.Errorf("username not found in context")
	}

	var req struct {
		LobbyID string `json:"lobby_id"`
	}
	
	if err := json.Unmarshal([]byte(payload), &req); err != nil {
		return "", fmt.Errorf("invalid payload: %v", err)
	}

	lobbyID := req.LobbyID
	
	// Check if lobby exists
	lobby, exists := lobbyManager.lobbies[lobbyID]
	if !exists {
		return "", fmt.Errorf("lobby does not exist")
	}

	// Check if lobby is private
	if lobby.IsPrivate {
		// Only creator and invited players can join
		// Implementation would check invitations here
	}

	// Check if lobby is full
	if lobby.CurrentPlayers >= lobby.MaxPlayers {
		return "", fmt.Errorf("lobby is full")
	}

	// Check if player is already in this lobby
	for _, player := range lobbyManager.players[lobbyID] {
		if player.UserID == userID {
			return "", fmt.Errorf("player already in lobby")
		}
	}

	// Add player to lobby
	player := &LobbyPlayer{
		UserID:   userID,
		Username: username,
		Ready:    false,
	}
	
	lobbyManager.players[lobbyID] = append(lobbyManager.players[lobbyID], player)
	lobby.CurrentPlayers++
	lobby.LastActivity = time.Now()

	// Prepare response
	response := map[string]interface{}{
		"lobby_id":     lobby.ID,
		"name":         lobby.Name,
		"max_players":  lobby.MaxPlayers,
		"current_players": lobby.CurrentPlayers,
		"is_private":   lobby.IsPrivate,
		"custom_properties": lobby.CustomProps,
		"created_by":   lobby.CreatedBy,
		"players": convertPlayersToMap(lobbyManager.players[lobbyID]),
	}

	// Notify other players in lobby about new member
	go notifyPlayerJoined(lobbyID, player)

	logger.Info(fmt.Sprintf("User %s joined lobby %s", userID, lobbyID))
	
	jsonResp, err := json.Marshal(response)
	if err != nil {
		return "", fmt.Errorf("failed to marshal response: %v", err)
	}

	return string(jsonResp), nil
}

// joinLobbyByCode allows a player to join a lobby using an access code
func joinLobbyByCode(ctx context.Context, logger runtime.Logger, db *sql.DB, nk runtime.NakamaModule, payload string) (string, error) {
	// Implementation similar to joinLobby but looks up lobby by code
	// This requires storing and maintaining lobby codes separately
	// For simplicity, assuming direct mapping of code to lobby ID in this example
	var req struct {
		Code string `json:"code"`
	}
	
	if err := json.Unmarshal([]byte(payload), &req); err != nil {
		return "", fmt.Errorf("invalid payload: %v", err)
	}

	// In a real implementation, you'd look up the lobby ID from the code
	// For now, we'll treat the code as the lobby ID
	lobbyID := req.Code

	// Forward to joinLobby logic
	forwardPayload := fmt.Sprintf(`{"lobby_id":"%s"}`, lobbyID)
	return joinLobby(ctx, logger, db, nk, forwardPayload)
}

// leaveLobby removes a player from a lobby
func leaveLobby(ctx context.Context, logger runtime.Logger, db *sql.DB, nk runtime.NakamaModule, payload string) (string, error) {
	userID, ok := ctx.Value(runtime.RUNTIME_CTX_USER_ID).(string)
	if !ok {
		return "", fmt.Errorf("user ID not found in context")
	}

	var req struct {
		LobbyID string `json:"lobby_id"`
	}
	
	if err := json.Unmarshal([]byte(payload), &req); err != nil {
		return "", fmt.Errorf("invalid payload: %v", err)
	}

	lobbyID := req.LobbyID
	
	// Check if lobby exists
	_, exists := lobbyManager.lobbies[lobbyID]
	if !exists {
		return "", fmt.Errorf("lobby does not exist")
	}

	// Find and remove player from lobby
	updatedPlayers := []*LobbyPlayer{}
	playerFound := false
	players := lobbyManager.players[lobbyID]
	
	for _, player := range players {
		if player.UserID != userID {
			updatedPlayers = append(updatedPlayers, player)
		} else {
			playerFound = true
		}
	}

	if !playerFound {
		return "", fmt.Errorf("player not in lobby")
	}

	// Update lobby state
	lobbyManager.players[lobbyID] = updatedPlayers
	lobbyManager.lobbies[lobbyID].CurrentPlayers--
	lobbyManager.lobbies[lobbyID].LastActivity = time.Now()

	// If lobby becomes empty, clean it up
	if len(updatedPlayers) == 0 {
		delete(lobbyManager.lobbies, lobbyID)
		delete(lobbyManager.players, lobbyID)
	} else if userID == lobbyManager.lobbies[lobbyID].CreatedBy {
		// If creator leaves, assign new creator
		lobbyManager.lobbies[lobbyID].CreatedBy = updatedPlayers[0].UserID
	}

	// Notify other players in lobby about leaving member
	playerLeft := findPlayerByID(players, userID)
	if playerLeft != nil {
		go notifyPlayerLeft(lobbyID, playerLeft)
	}

	logger.Info(fmt.Sprintf("User %s left lobby %s", userID, lobbyID))
	
	response := map[string]interface{}{
		"success": true,
		"lobby_id": lobbyID,
	}
	
	jsonResp, err := json.Marshal(response)
	if err != nil {
		return "", fmt.Errorf("failed to marshal response: %v", err)
	}

	return string(jsonResp), nil
}

// searchLobbies returns public lobbies matching the filter criteria
func searchLobbies(ctx context.Context, logger runtime.Logger, db *sql.DB, nk runtime.NakamaModule, payload string) (string, error) {
	var req struct {
		Filter map[string]interface{} `json:"filter"`
	}
	
	if err := json.Unmarshal([]byte(payload), &req); err != nil {
		return "", fmt.Errorf("invalid payload: %v", err)
	}

	// Apply filters and collect public lobbies
	publicLobbies := []map[string]interface{}{}
	
	for _, lobby := range lobbyManager.lobbies {
		// Skip private lobbies
		if lobby.IsPrivate {
			continue
		}

		// Apply additional filters if provided
		matches := true
		
		if minPlayers, ok := req.Filter["min_players"].(float64); ok {
			if float64(lobby.CurrentPlayers) < minPlayers {
				matches = false
			}
		}
		
		if maxPlayers, ok := req.Filter["max_players"].(float64); ok {
			if float64(lobby.CurrentPlayers) > maxPlayers {
				matches = false
			}
		}
		
		if gameMode, ok := req.Filter["game_mode"].(string); ok {
			if mode, ok := lobby.CustomProps["game_mode"].(string); ok {
				if mode != gameMode {
					matches = false
				}
			} else {
				matches = false
			}
		}

		if matches {
			publicLobbies = append(publicLobbies, map[string]interface{}{
				"lobby_id": lobby.ID,
				"name":     lobby.Name,
				"max_players": lobby.MaxPlayers,
				"current_players": lobby.CurrentPlayers,
				"is_private": lobby.IsPrivate,
				"custom_properties": lobby.CustomProps,
				"created_by": lobby.CreatedBy,
				"created_at": lobby.CreatedAt.Format(time.RFC3339),
			})
		}
	}

	response := map[string]interface{}{
		"lobbies": publicLobbies,
	}
	
	jsonResp, err := json.Marshal(response)
	if err != nil {
		return "", fmt.Errorf("failed to marshal response: %v", err)
	}

	return string(jsonResp), nil
}

// getLobbyInfo returns information about a specific lobby
func getLobbyInfo(ctx context.Context, logger runtime.Logger, db *sql.DB, nk runtime.NakamaModule, payload string) (string, error) {
	var req struct {
		LobbyID string `json:"lobby_id"`
	}
	
	if err := json.Unmarshal([]byte(payload), &req); err != nil {
		return "", fmt.Errorf("invalid payload: %v", err)
	}

	lobbyID := req.LobbyID
	
	lobby, exists := lobbyManager.lobbies[lobbyID]
	if !exists {
		return "", fmt.Errorf("lobby does not exist")
	}

	response := map[string]interface{}{
		"lobby_id": lobby.ID,
		"name":     lobby.Name,
		"max_players": lobby.MaxPlayers,
		"current_players": lobby.CurrentPlayers,
		"is_private": lobby.IsPrivate,
		"custom_properties": lobby.CustomProps,
		"created_by": lobby.CreatedBy,
		"created_at": lobby.CreatedAt.Format(time.RFC3339),
		"last_activity": lobby.LastActivity.Format(time.RFC3339),
		"players": convertPlayersToMap(lobbyManager.players[lobbyID]),
	}
	
	jsonResp, err := json.Marshal(response)
	if err != nil {
		return "", fmt.Errorf("failed to marshal response: %v", err)
	}

	return string(jsonResp), nil
}

// sendLobbyInvite sends an invitation to another player to join a lobby
func sendLobbyInvite(ctx context.Context, logger runtime.Logger, db *sql.DB, nk runtime.NakamaModule, payload string) (string, error) {
	userID, ok := ctx.Value(runtime.RUNTIME_CTX_USER_ID).(string)
	if !ok {
		return "", fmt.Errorf("user ID not found in context")
	}

	var req struct {
		ToUserID string `json:"to_user_id"`
		LobbyID  string `json:"lobby_id"`
	}
	
	if err := json.Unmarshal([]byte(payload), &req); err != nil {
		return "", fmt.Errorf("invalid payload: %v", err)
	}

	// Validate that sender is in the lobby
	senderInLobby := false
	for _, players := range lobbyManager.players {
		for _, player := range players {
			if player.UserID == userID {
				senderInLobby = true
				break
			}
		}
		if senderInLobby {
			break
		}
	}
	
	if !senderInLobby {
		return "", fmt.Errorf("sender must be in a lobby to send invites")
	}

	// In a real implementation, you would store the invitation and potentially
	// send a notification to the recipient
	
	// For now, just acknowledge the invite was sent
	response := map[string]interface{}{
		"success": true,
		"to_user_id": req.ToUserID,
		"lobby_id": req.LobbyID,
		"from_user_id": userID,
	}
	
	jsonResp, err := json.Marshal(response)
	if err != nil {
		return "", fmt.Errorf("failed to marshal response: %v", err)
	}

	return string(jsonResp), nil
}

// startGame begins the game for players in the lobby
func startGame(ctx context.Context, logger runtime.Logger, db *sql.DB, nk runtime.NakamaModule, payload string) (string, error) {
	userID, ok := ctx.Value(runtime.RUNTIME_CTX_USER_ID).(string)
	if !ok {
		return "", fmt.Errorf("user ID not found in context")
	}

	var req struct {
		LobbyID  string                 `json:"lobby_id"`
		Settings map[string]interface{} `json:"settings"`
	}
	
	if err := json.Unmarshal([]byte(payload), &req); err != nil {
		return "", fmt.Errorf("invalid payload: %v", err)
	}

	lobbyID := req.LobbyID
	
	// Verify user is lobby owner
	lobby, exists := lobbyManager.lobbies[lobbyID]
	if !exists {
		return "", fmt.Errorf("lobby does not exist")
	}
	
	if lobby.CreatedBy != userID {
		return "", fmt.Errorf("only lobby creator can start the game")
	}

	// In a real implementation, this would transition players to a game match
	// and potentially create a new authoritative game server instance
	
	// For now, just acknowledge the game start request
	response := map[string]interface{}{
		"success": true,
		"lobby_id": lobbyID,
		"message": "Game starting...",
	}
	
	jsonResp, err := json.Marshal(response)
	if err != nil {
		return "", fmt.Errorf("failed to marshal response: %v", err)
	}

	return string(jsonResp), nil
}

// Helper functions

// generateLobbyID creates a unique identifier for a lobby
func generateLobbyID() string {
	// In a production environment, you'd want a more robust ID generation
	// This is simplified for demonstration purposes
	return fmt.Sprintf("lobby_%d", time.Now().UnixNano())
}

// convertPlayersToMap converts lobby players to a serializable map format
func convertPlayersToMap(players []*LobbyPlayer) []map[string]interface{} {
	result := make([]map[string]interface{}, len(players))
	for i, player := range players {
		result[i] = map[string]interface{}{
			"user_id": player.UserID,
			"username": player.Username,
			"ready": player.Ready,
		}
	}
	return result
}

// findPlayerByID finds a player by their user ID in a list of players
func findPlayerByID(players []*LobbyPlayer, userID string) *LobbyPlayer {
	for _, player := range players {
		if player.UserID == userID {
			return player
		}
	}
	return nil
}

// notifyLobbyUpdate sends updates to all players in a lobby
func notifyLobbyUpdate(lobbyID string) {
	// This would send real-time notifications to lobby members
	// Implementation depends on Nakama's notification system
}

// notifyPlayerJoined notifies all players in a lobby about a new member
func notifyPlayerJoined(lobbyID string, player *LobbyPlayer) {
	// This would send real-time notifications to lobby members
	// Implementation depends on Nakama's notification system
}

// notifyPlayerLeft notifies all players in a lobby about a departing member
func notifyPlayerLeft(lobbyID string, player *LobbyPlayer) {
	// This would send real-time notifications to lobby members
	// Implementation depends on Nakama's notification system
}