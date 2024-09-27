extends Node2D

class_name BSPTree

@export var map_width: int = 32
@export var map_height: int = 32
@export var min_leaf_size: int = 8
@export var max_leaf_size: int = 30
@onready var player_scene = preload("res://Scenes/gridPlayer.tscn")
var player

var tilemaplayer: TileMapLayer
var fog_of_war: TileMapLayer

const FOG_TILE_INDEX = 0  # Index of your fog tile in the tileset
const VISIBILITY_RADIUS = 1  # Number of tiles the player can see
const TILE_SIZE = Vector2i(32, 32)

const UP_STAIR_TILE_INDEX = 3
const DOWN_STAIR_TILE_INDEX = 0

var visited_tiles = {}
var root_leaf: Leaf

var current_floor: int = 0
var floors = {}

func _ready():
	tilemaplayer = get_node("TileMapLayer2")

	root_leaf = Leaf.new(Rect2(Vector2(0, 0), Vector2(map_width, map_height)))  # Use tile dimensions for the BSP

	# Split and create rooms
	root_leaf.split(min_leaf_size, max_leaf_size)
	root_leaf.create_rooms()

	fog_of_war = get_node("FogOfWar") as TileMapLayer
	initialize_fog()

	player = player_scene.instantiate()
	add_child(player)
	place_player()
	#place_stairs()

	player.connect("tile_changed", Callable(self, "_on_player_tile_changed"))
	player.connect("room_changed", Callable(self, "_on_player_room_changed"))
	player.connect("stairs_up", Callable(self, "_on_stairs_up"))
	player.connect("stairs_down", Callable(self, "_on_stairs_down"))
	update_fog()

func _draw():
	# Draw background
	for x in range(map_width):
		for y in range(map_height):
			tilemaplayer.set_cell(Vector2i(x, y), 2, Vector2i(0, 0))  # Assuming tile 2 is the wall

	# Draw rooms onto the TileMap
	draw_rooms()
	# Draw corridors onto the TileMap
	draw_corridors()
	place_stairs()
	
func generate_new_floor():
	clear_floor()

	root_leaf = Leaf.new(Rect2(Vector2(0, 0), Vector2(map_width, map_height)))
	root_leaf.split(min_leaf_size, max_leaf_size)
	root_leaf.create_rooms()
	_draw()
	initialize_fog()
	place_player()
	update_fog()
	#place_stairs()
	
func place_stairs():
	var rooms = root_leaf.get_all_rooms()
	if rooms.size() >= 2:
		var up_stair_room = rooms[0]
		var down_stair_room = rooms[1]

		# Place up stairs
		var up_stair_pos = up_stair_room.get_random_tile_position()
		print("up_stair_pos:", up_stair_pos)
		tilemaplayer.set_cell(up_stair_pos, UP_STAIR_TILE_INDEX, Vector2i(0, 0))

		# Place down stairs
		var down_stair_pos = down_stair_room.get_random_tile_position()
		print("down_stair_pos:", down_stair_pos)
		tilemaplayer.set_cell(down_stair_pos, DOWN_STAIR_TILE_INDEX, Vector2i(0, 0))

func clear_floor():
	tilemaplayer.clear()
	fog_of_war.clear()
	visited_tiles.clear()

func save_current_floor():
	var floor_data = {
		"map": [],
		"fog": [],
		"player_position": player.position,
		"visited_tiles": visited_tiles.duplicate()
	}

	# Save all cells for the tilemap layer (map)
	for cell_pos in tilemaplayer.get_used_cells():
		var tile_index = tilemaplayer.get_cell_source_id(cell_pos)
		floor_data["map"].append({"position": cell_pos, "tile_index": tile_index})

	# Save all cells for the fog of war layer
	for fog_pos in fog_of_war.get_used_cells():
		var fog_index = fog_of_war.get_cell_source_id(fog_pos)
		floor_data["fog"].append({"position": fog_pos, "fog_index": fog_index})

	floors[current_floor] = floor_data

func load_floor(floor_number: int):
	clear_floor()  # Clear existing floor before loading
	var floor_data = floors[floor_number]

	# Restore the map (tilemap layer)
	for cell_data in floor_data["map"]:
		tilemaplayer.set_cell(Vector2i(cell_data["position"]), cell_data["tile_index"], Vector2i(0, 0))

	# Restore the fog of war (fog layer)
	for fog_data in floor_data["fog"]:
		fog_of_war.set_cell(Vector2i(fog_data["position"]), fog_data["fog_index"], Vector2i(0, 0))

	# Restore player position
	player.position = floor_data["player_position"]

	# Restore visited tiles
	visited_tiles = floor_data["visited_tiles"].duplicate()

	update_fog()

	
func change_floor(floor_number: int):
	save_current_floor()
	current_floor = floor_number

	if floors.has(current_floor):
		load_floor(current_floor)
	else:
		generate_new_floor()

func initialize_fog():
	for x in range(map_width):
		for y in range(map_height):
			fog_of_war.set_cell(Vector2i(x, y), FOG_TILE_INDEX, Vector2i(0, 0))

func update_fog():
	var player_tile_pos = Vector2i(
		int(player.position.x / TILE_SIZE.x),
		int(player.position.y / TILE_SIZE.y)
	)

	# Always update fog around the player
	for x_offset in range(-VISIBILITY_RADIUS, VISIBILITY_RADIUS + 1):
		for y_offset in range(-VISIBILITY_RADIUS, VISIBILITY_RADIUS + 1):
			var x = player_tile_pos.x + x_offset
			var y = player_tile_pos.y + y_offset
			var tile_pos = Vector2i(x, y)

			if x >= 0 and x < map_width and y >= 0 and y < map_height:
				fog_of_war.set_cell(Vector2i(x, y), -1)  # Remove fog tile
				visited_tiles[tile_pos] = true

func _on_player_room_changed(room: Room):
	print("Player entered a new room.")
	reveal_room(room)

func _on_player_tile_changed(new_tile_pos):
	update_fog()
	
func _on_stairs_up():
	print("Player is going up the stairs.")
	change_floor(current_floor + 1)

func _on_stairs_down():
	print("Player is going down the stairs.")
	change_floor(current_floor - 1)

func place_player():
	var starting_room = get_random_room()
	if starting_room == null:
		return

	var player_tile_pos = starting_room.get_random_tile_position()
	var player_local_pos = player_tile_pos * TILE_SIZE
	var player_world_pos = tilemaplayer.to_global(player_local_pos)

	# Adjust player's position to center within the tile
	player.position = player_world_pos + Vector2(TILE_SIZE) / 2

func draw_rooms():
	var rooms = root_leaf.get_all_rooms()
	for room in rooms:
		room.draw_room(tilemaplayer)

func reveal_room(room: Room):
	var start_x = int(room.rect.position.x)
	var start_y = int(room.rect.position.y)
	var end_x = int(room.rect.position.x + room.rect.size.x)
	var end_y = int(room.rect.position.y + room.rect.size.y)

	for x in range(start_x, end_x):
		for y in range(start_y, end_y):
			fog_of_war.set_cell(Vector2i(x, y), -1)  # Remove fog tile
			visited_tiles[Vector2i(x, y)] = true

func get_rooms() -> Array:
	return root_leaf.get_all_rooms()

func get_random_room() -> Room:
	var rooms = root_leaf.get_all_rooms()
	if rooms.size() == 0:
		return null  # No rooms available
	return rooms[randi() % rooms.size()]

func draw_corridors():
	var corridors = root_leaf.get_all_corridors()
	for corridor in corridors:
		var start_x = int(corridor.position.x)
		var start_y = int(corridor.position.y)
		var end_x = int(corridor.position.x + corridor.size.x)
		var end_y = int(corridor.position.y + corridor.size.y)

		for x in range(start_x, end_x):
			for y in range(start_y, end_y):
				if x >= 0 and x < map_width and y >= 0 and y < map_height:
					tilemaplayer.set_cell(Vector2i(x, y), 1, Vector2i(0, 0))  # Assuming tile 1 is the floor

func generate_map_array() -> Array:
	var map_array = []
	for y in range(map_height):
		var row = []
		for x in range(map_width):
			row.append('#')  # Initialize with wall
		map_array.append(row)

	# Draw rooms
	var rooms = root_leaf.get_all_rooms()
	for room in rooms:
		var start_x = int(room.rect.position.x)
		var start_y = int(room.rect.position.y)
		var end_x = int(room.rect.position.x + room.rect.size.x)
		var end_y = int(room.rect.position.y + room.rect.size.y)
		for y in range(start_y, end_y):
			for x in range(start_x, end_x):
				if x >= 0 and x < map_width and y >= 0 and y < map_height:
					map_array[y][x] = '.'  # Floor

	# Draw corridors
	var corridors = root_leaf.get_all_corridors()
	for corridor in corridors:
		var start_x = int(corridor.position.x)
		var start_y = int(corridor.position.y)
		var end_x = int(corridor.position.x + corridor.size.x)
		var end_y = int(corridor.position.y + corridor.size.y)
		for y in range(start_y, end_y):
			for x in range(start_x, end_x):
				if x >= 0 and x < map_width and y >= 0 and y < map_height:
					map_array[y][x] = '.'  # Floor
	return map_array

func print_map():
	var map_array = generate_map_array()
	for row in map_array:
		print(''.join(row))

func get_room_at_position(position: Vector2) -> Room:
	var rooms = root_leaf.get_all_rooms()
	for room in rooms:
		if room.contains_point(position):
			return room
	return null
