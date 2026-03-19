extends RefCounted
class_name Protocol

# Network opcodes - уникальные идентификаторы пакетов
# Диапазоны:
# 0-99: системные
# 100-199: авторизация
# 200-299: игровое состояние
# 300-399: чат
# 400-499: матчмейкинг

enum Opcode {
	# System (0-99)
	PING = 0,
	PONG = 1,
	HELLO = 2,
	GOODBYE = 3,
	DISCONNECT = 4,
	
	# Auth (100-199)
	AUTH_REQUEST = 100,
	AUTH_RESPONSE = 101,
	AUTH_FAILED = 102,
	HEARTBEAT = 103,
	
	# Game State (200-299)
	PLAYER_JOIN = 200,
	PLAYER_LEAVE = 201,
	PLAYER_MOVE = 202,
	PLAYER_STATE = 203,
	WORLD_UPDATE = 204,
	ENTITY_SPAWN = 205,
	ENTITY_DESPAWN = 206,
	ENTITY_MOVE = 207,
	COMBAT_DAMAGE = 208,
	COMBAT_HEAL = 209,
	INVENTORY_UPDATE = 210,
	SKILL_CAST = 211,
	
	# Chat (300-399)
	CHAT_MESSAGE = 300,
	CHAT_BROADCAST = 301,
	
	# Matchmaking (400-499)
	MATCH_FIND = 400,
	MATCH_FOUND = 401,
	MATCH_START = 402,
	MATCH_END = 403,
}

# Player state flags
enum PlayerState {
	NORMAL = 0,
	COMBAT = 1,
	DEAD = 2,
	AFK = 3,
	IN_MENU = 4,
}

# Entity types
enum EntityType {
	PLAYER = 0,
	NPC = 1,
	MONSTER = 2,
	ITEM = 3,
	PROJECTILE = 4,
}

# Compression flags
const COMPRESSED: int = 0x80
const ENCRYPTED: int = 0x40

# Max sizes
const MAX_PLAYERS_PER_SERVER: int = 64
const MAX_PACKET_SIZE: int = 65535
const TICK_RATE: int = 20  # 20 ticks per second
const TICK_INTERVAL: float = 1.0 / TICK_RATE

# Version check
const PROTOCOL_VERSION: int = 1


static func encode_varint(value: int) -> PackedByteArray:
	var result := PackedByteArray()
	while value > 0x7F:
		result.append((value & 0x7F) | 0x80)
		value >>= 7
	result.append(value & 0x7F)
	return result


static func decode_varint(data: PackedByteArray, offset: int) -> Array:
	var result := 0
	var shift := 0
	var pos := offset
	
	while pos < data.size():
		var b := data[pos]
		result |= (b & 0x7F) << shift
		pos += 1
		if (b & 0x80) == 0:
			break
		shift += 7
	
	return [result, pos - offset]
