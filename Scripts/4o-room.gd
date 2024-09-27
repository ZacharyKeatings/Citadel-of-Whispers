extends Node2D

class_name Room

var rect: Rect2
const TILE_SIZE = Vector2(32, 32)

func _init(_rect: Rect2):
	rect = _rect

func draw_room(tilemap: TileMapLayer):
	var start_x = int(rect.position.x)
	var start_y = int(rect.position.y)
	var end_x = int(rect.position.x + rect.size.x)
	var end_y = int(rect.position.y + rect.size.y)

	for x in range(start_x, end_x):
		for y in range(start_y, end_y):
			tilemap.set_cell(Vector2i(x, y), 1, Vector2i(0, 0))  # Assuming tile 1 is the floor

func get_center() -> Vector2:
	var center_x = int(rect.position.x + rect.size.x / 2)
	var center_y = int(rect.position.y + rect.size.y / 2)
	return Vector2(center_x, center_y)
	
func get_random_tile_position() -> Vector2i:
	var start_x = int(rect.position.x)
	var start_y = int(rect.position.y)
	var end_x = int(rect.position.x + rect.size.x)
	var end_y = int(rect.position.y + rect.size.y)

	var x = randi_range(start_x, end_x - 1)
	var y = randi_range(start_y, end_y - 1)

	return Vector2i(x, y)
	
func contains_point(point: Vector2) -> bool:
	var room_rect = Rect2(
		rect.position * TILE_SIZE,
		rect.size * TILE_SIZE
	)
	return room_rect.has_point(point)
