extends Node2D

class_name Leaf

var rect: Rect2
var left_child: Leaf = null
var right_child: Leaf = null
var room: Room = null
var corridors: Array = []

func _init(_rect: Rect2):
	rect = _rect

func split(min_size: int, max_size: int) -> bool:
	if left_child or right_child:
		return false  # Already split

	var should_split = false

	if rect.size.x > max_size or rect.size.y > max_size:
		should_split = true
	elif randf() > 0.25:
		should_split = true

	if not should_split:
		return false

	var split_horizontally = randf() > 0.5
	if rect.size.x / rect.size.y >= 1.25:
		split_horizontally = false
	elif rect.size.y / rect.size.x >= 1.25:
		split_horizontally = true

	var max_split = (rect.size.y - min_size) if split_horizontally else (rect.size.x - min_size)
	if max_split <= min_size:
		return false  # Cannot split anymore

	var split_point = randi_range(min_size, int(max_split))

	if split_horizontally:
		left_child = Leaf.new(Rect2(rect.position, Vector2(rect.size.x, split_point)))
		right_child = Leaf.new(Rect2(rect.position + Vector2(0, split_point), Vector2(rect.size.x, rect.size.y - split_point)))
	else:
		left_child = Leaf.new(Rect2(rect.position, Vector2(split_point, rect.size.y)))
		right_child = Leaf.new(Rect2(rect.position + Vector2(split_point, 0), Vector2(rect.size.x - split_point, rect.size.y)))

	left_child.split(min_size, max_size)
	right_child.split(min_size, max_size)
	return true

func create_rooms():
	if left_child or right_child:
		if left_child:
			left_child.create_rooms()
		if right_child:
			right_child.create_rooms()
		if left_child and right_child:
			create_corridor_between(
				left_child.get_room(), right_child.get_room()
			)
	else:
		# Create a room as before
		var room_size = Vector2(
			randi_range(int(rect.size.x * 0.5), int(rect.size.x * 0.8)),
			randi_range(int(rect.size.y * 0.5), int(rect.size.y * 0.8))
		)
		var room_pos = Vector2(
			randi_range(int(rect.position.x + 1), int(rect.position.x + rect.size.x - room_size.x - 1)),
			randi_range(int(rect.position.y + 1), int(rect.position.y + rect.size.y - room_size.y - 1))
		)
		room = Room.new(Rect2(room_pos, room_size))

func create_corridor_between(room1: Room, room2: Room):
	var point1 = room1.get_center()
	var point2 = room2.get_center()

	if randf() > 0.5:
		# Horizontal first, then vertical
		create_h_corridor(int(point1.x), int(point2.x), int(point1.y))
		create_v_corridor(int(point1.y), int(point2.y), int(point2.x))
	else:
		# Vertical first, then horizontal
		create_v_corridor(int(point1.y), int(point2.y), int(point1.x))
		create_h_corridor(int(point1.x), int(point2.x), int(point2.y))
		
func create_h_corridor(x1: int, x2: int, y: int):
	var start_x = min(x1, x2)
	var end_x = max(x1, x2)
	var corridor_rect = Rect2(Vector2(start_x, y), Vector2(end_x - start_x + 1, 1))
	corridors.append(corridor_rect)

func create_v_corridor(y1: int, y2: int, x: int):
	var start_y = min(y1, y2)
	var end_y = max(y1, y2)
	var corridor_rect = Rect2(Vector2(x, start_y), Vector2(1, end_y - start_y + 1))
	corridors.append(corridor_rect)
		
		
func get_all_corridors() -> Array:
	var all_corridors = corridors.duplicate()
	if left_child:
		all_corridors.append_array(left_child.get_all_corridors())
	if right_child:
		all_corridors.append_array(right_child.get_all_corridors())
	return all_corridors
	
func get_all_rooms() -> Array:
	var rooms: Array = []
	if room:
		rooms.append(room)
	else:
		if left_child:
			rooms.append_array(left_child.get_all_rooms())
		if right_child:
			rooms.append_array(right_child.get_all_rooms())
	return rooms
	
func get_room() -> Room:
	if room:
		return room
	else:
		var left_room = null
		var right_room = null
		if left_child:
			left_room = left_child.get_room()
		if right_child:
			right_room = right_child.get_room()
		if left_room and right_room:
			if randf() > 0.5:
				return left_room
			else:
				return right_room
		elif left_room:
			return left_room
		elif right_room:
			return right_room
		else:
			return null
