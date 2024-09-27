extends Area2D
class_name Player

signal room_changed(room)
signal tile_changed(new_tile_pos)
signal stairs_up
signal stairs_down

const TILE_SIZE = Vector2i(32, 32)
var tile_size = 32

var previous_tile_pos = Vector2i(-1, -1)
var current_room: Room = null
var bsp_tree: BSPTree

var move_direction = Vector2.ZERO
var is_moving = false

var on_stair_tile: int = -1  # -1 indicates not on a stair tile
const UP_STAIR_TILE_INDEX = 3
const DOWN_STAIR_TILE_INDEX = 0

const MOVE_TIME: float = 0.2  # Time to move to the next tile
const MOVE_DELAY: float = 0.2  # Delay between moves

@onready var ray = $RayCast2D

func _ready():
	bsp_tree = get_parent() as BSPTree
	position = position.snapped(Vector2.ONE * tile_size)
	position += Vector2.ONE * tile_size / 2
	update_current_room()

func _physics_process(delta):
	if is_moving:
		return

	# Check for input
	var input_vector = Vector2.ZERO
	if Input.is_action_pressed("ui_right"):
		input_vector.x += 1
	if Input.is_action_pressed("ui_left"):
		input_vector.x -= 1
	if Input.is_action_pressed("ui_down"):
		input_vector.y += 1
	if Input.is_action_pressed("ui_up"):
		input_vector.y -= 1
	input_vector = input_vector.normalized()

	if input_vector != Vector2.ZERO:
		move_direction = input_vector
		move()
		
func _unhandled_input(event):
	if event.is_action_pressed("use_stairs"):
		print("use stairs hotkey")
		if on_stair_tile == bsp_tree.UP_STAIR_TILE_INDEX:
			print("up")
			emit_signal("stairs_up")
		elif on_stair_tile == bsp_tree.DOWN_STAIR_TILE_INDEX:
			print("down")
			emit_signal("stairs_down")

func move():
	if is_moving:
		return

	# Setup the ray for collision detection
	ray.target_position = move_direction * tile_size
	ray.force_raycast_update()

	# Check for collision
	if !ray.is_colliding():
		is_moving = true
		var target_position = position + move_direction * tile_size

		# Move the player to the next tile over time
		var tween = create_tween()
		tween.tween_property(self, "position", target_position, MOVE_TIME)
		tween.set_trans(Tween.TRANS_LINEAR)
		tween.set_ease(Tween.EASE_IN_OUT)
		tween.connect("finished", Callable(self, "_on_move_finished"))

		# Update tile position and emit signals after movement is finished
	else:
		# Can't move; reset move_direction
		move_direction = Vector2.ZERO

func _on_move_finished():
	is_moving = false

	# Update tile position and emit signals
	var current_tile_pos = Vector2i(
		int(position.x / TILE_SIZE.x),
		int(position.y / TILE_SIZE.y)
	)
	if current_tile_pos != previous_tile_pos:
		emit_signal("tile_changed", current_tile_pos)
		previous_tile_pos = current_tile_pos
		
	# Check for stair tiles
	check_for_stairs(current_tile_pos)

	# Check for room change
	update_current_room()


	# Continue moving if the key is still held
	if Input.is_action_pressed("ui_right") and move_direction == Vector2.RIGHT:
		move()
	elif Input.is_action_pressed("ui_left") and move_direction == Vector2.LEFT:
		move()
	elif Input.is_action_pressed("ui_down") and move_direction == Vector2.DOWN:
		move()
	elif Input.is_action_pressed("ui_up") and move_direction == Vector2.UP:
		move()
	else:
		move_direction = Vector2.ZERO

func check_for_stairs(tile_pos: Vector2i):
	var tile_index = bsp_tree.tilemaplayer.get_cell_source_id(tile_pos)
	if tile_index == bsp_tree.UP_STAIR_TILE_INDEX:
		on_stair_tile = bsp_tree.UP_STAIR_TILE_INDEX
	elif tile_index == bsp_tree.DOWN_STAIR_TILE_INDEX:
		on_stair_tile = bsp_tree.DOWN_STAIR_TILE_INDEX
	else:
		on_stair_tile = -1

func update_current_room():
	var new_room = bsp_tree.get_room_at_position(position)
	if new_room != current_room:
		current_room = new_room
		if current_room != null:
			emit_signal("room_changed", current_room)
		else:
			emit_signal("tile_changed", previous_tile_pos)
