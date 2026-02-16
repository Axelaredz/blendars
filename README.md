# Yet Another Roguelike

## Overview
Yet Another Roguelike is a 3D roguelike game built with Godot 4.6. The project showcases a modern architecture for a multiplayer roguelike game with Nakama backend integration.

## Features
- Procedurally generated dungeons
- Turn-based combat system
- Character progression and inventory management
- Online multiplayer support
- Cloud saves and leaderboards

## Technologies Used
- Godot Engine 4.6
- GDScript
- Nakama Backend
- SQLite (for local caching)

## Installation
1. Install Godot Engine 4.6
2. Clone this repository
3. Open the project in Godot Editor
4. Run the game

## Architecture
The project follows a client-server architecture with the following components:
- Client: Handles rendering, UI, and user input
- Server: Manages game state, authentication, and multiplayer logic
- Shared: Contains common utilities and data structures

For more details, see the qwen.md file.