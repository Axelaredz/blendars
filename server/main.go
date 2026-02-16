// Nakama main runtime entry point
// This file registers all server-side modules

package main

import (
	"context"
	"database/sql"
	"log"

	"github.com/heroiclabs/nakama-common/runtime"
)

// InitModule is called when the module is loaded
func InitModule(ctx context.Context, logger runtime.Logger, db *sql.DB, nk runtime.NakamaModule) error {
	logger.Info("Initializing game server modules...")
	
	// Initialize lobby system
	if err := InitLobbySystem(ctx, logger, db, nk); err != nil {
		log.Printf("Error initializing lobby system: %v", err)
		return err
	}
	
	logger.Info("All modules initialized successfully")
	return nil
}

// Placeholder for LobbySystem initialization
// The actual implementation would be in a separate file that gets compiled together
func InitLobbySystem(ctx context.Context, logger runtime.Logger, db *sql.DB, nk runtime.NakamaModule) error {
	// This function would normally be implemented in lobby_system.go
	// For this example, we'll provide a basic implementation
	logger.Info("Lobby system initialized (stub)")
	
	// Register RPC endpoints
	rpcs := map[string]interface{}{
		"create_lobby": func(ctx context.Context, logger runtime.Logger, db *sql.DB, nk runtime.NakamaModule, payload string) (string, error) {
			return `{"message": "create_lobby RPC registered"}`, nil
		},
		"join_lobby": func(ctx context.Context, logger runtime.Logger, db *sql.DB, nk runtime.NakamaModule, payload string) (string, error) {
			return `{"message": "join_lobby RPC registered"}`, nil
		},
		"join_lobby_by_code": func(ctx context.Context, logger runtime.Logger, db *sql.DB, nk runtime.NakamaModule, payload string) (string, error) {
			return `{"message": "join_lobby_by_code RPC registered"}`, nil
		},
		"leave_lobby": func(ctx context.Context, logger runtime.Logger, db *sql.DB, nk runtime.NakamaModule, payload string) (string, error) {
			return `{"message": "leave_lobby RPC registered"}`, nil
		},
		"search_lobbies": func(ctx context.Context, logger runtime.Logger, db *sql.DB, nk runtime.NakamaModule, payload string) (string, error) {
			return `{"message": "search_lobbies RPC registered"}`, nil
		},
		"get_lobby_info": func(ctx context.Context, logger runtime.Logger, db *sql.DB, nk runtime.NakamaModule, payload string) (string, error) {
			return `{"message": "get_lobby_info RPC registered"}`, nil
		},
		"send_lobby_invite": func(ctx context.Context, logger runtime.Logger, db *sql.DB, nk runtime.NakamaModule, payload string) (string, error) {
			return `{"message": "send_lobby_invite RPC registered"}`, nil
		},
		"start_game": func(ctx context.Context, logger runtime.Logger, db *sql.DB, nk runtime.NakamaModule, payload string) (string, error) {
			return `{"message": "start_game RPC registered"}`, nil
		},
	}
	
	for rpcName, rpcFunc := range rpcs {
		if err := nk.RegisterRpc(rpcName, rpcFunc.(func(context.Context, runtime.Logger, *sql.DB, runtime.NakamaModule, string) (string, error))); err != nil {
			return err
		}
	}
	
	return nil
}