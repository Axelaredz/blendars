# BLEND ARS - Multiplayer Game Project

BLEND ARS is a multiplayer game built with Godot engine that uses Nakama server for networking and real-time gameplay.

## Table of Contents
- [Project Structure](#project-structure)
- [Features](#features)
- [Technologies Used](#technologies-used)
- [Setup Instructions](#setup-instructions)
- [Architecture](#architecture)
- [Development](#development)
- [License](#license)

## Project Structure

```
├── ARCHITECTURE.md           # Architecture documentation
├── client/                   # Godot client-side code
├── codegen/                  # Code generation utilities
├── core/                     # Core game systems
│   ├── autoload/             # Autoload scripts
│   └── networking/           # Networking implementation
├── godot-project/            # Godot project files
├── infrastructure/           # Docker and deployment configs
├── nakama/                   # Nakama server configuration
├── nakama-server/            # Nakama TypeScript modules
├── src/                      # Shared source code
├── test/                     # Test files
└── manage.sh                 # Management script
```

## Important Notice

⚠️ This project is currently under active development. As such, it is not recommended to copy or use this project in its current state.

## Features

- Real-time multiplayer functionality using Nakama server
- Docker-based deployment
- Code generation utilities
- Cross-platform support
- Networking abstraction layer
- Integration with NetFox networking library (https://github.com/foxssake/netfox)

## Technologies Used

- [Godot Engine](https://godotengine.org/) - Game engine
- [Nakama](https://heroiclabs.com/nakama) - Backend server for games
- [Docker](https://www.docker.com/) - Containerization
- [TypeScript](https://www.typescriptlang.org/) - Server-side scripting
- Go - Code generation tools

## Setup Instructions

### Prerequisites

- Godot Engine (latest stable version)
- Docker and Docker Compose
- Node.js (for Nakama modules)
- Go (for code generation)

### Running the Project

1. Clone the repository:
   ```bash
   git clone <repository-url>
   cd blendars
   ```

2. Start the Nakama server:
   ```bash
   docker-compose -f infrastructure/docker-compose.local.yml up -d
   ```

3. Open the project in Godot and run the main scene.

4. For development, use the management script:
   ```bash
   ./manage.sh
   ```

## Architecture

For detailed architecture information, see [ARCHITECTURE.md](./ARCHITECTURE.md).

The project follows a client-server architecture with:
- Godot client handling game presentation and user interaction
- Nakama server managing multiplayer sessions, authentication, and real-time communication
- Docker containers for easy deployment and scaling

## Development

### Client-Side Development

The client code is located in the `client/` directory. It includes:
- UI components
- Shaders
- Game logic
- Networking client code

### Server-Side Development

Server modules are located in `nakama-server/src/` and written in TypeScript. They handle:
- Authentication
- Matchmaking
- Real-time gameplay logic
- Database interactions

### Code Generation

The `codegen/` directory contains utilities for generating repetitive code, written in Go.

## License

See [LICENSE](./LICENSE) file for licensing information.

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Submit a pull request

## Support

For support, please check the issues section or contact the maintainers.
