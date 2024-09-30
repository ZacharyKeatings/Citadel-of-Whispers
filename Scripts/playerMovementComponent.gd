extends Node

class_name PlayerMovementComponent

# Signals
signal tile_changed(new_tile_pos)
signal room_changed(room)
signal stairs_up
signal stairs_down

# Movement constants
const TILE_SIZE = Vector2i(32, 32)
const MOVE_TIME: float = 0.2  # Time to move to the next tile
const MOVE_DELAY: float = 0.2  # Delay between moves

# Movement variables
var tile_size = 32
var move_direction = Vector2.ZERO
var is_moving = false
var previous_tile_pos = Vector2i(-1, -1)
var on_stair_tile: int = -1  # -1 indicates not on a stair tile

# References
var player
var bsp_tree
var current_room: Room = null

# Stair tile indices
const UP_STAIR_TILE_INDEX = 3
const DOWN_STAIR_TILE_INDEX = 0

# Input mapping
var input_actions = {
	"ui_right": Vector2.RIGHT,
	"ui_left": Vector2.LEFT,
	"ui_down": Vector2.DOWN,
	"ui_up": Vector2.UP
}

func _init(_player, _bsp_tree):
	player = _player
	bsp_tree = _bsp_tree
	player.position = player.position.snapped(Vector2.ONE * tile_size)
	player.position += Vector2.ONE * tile_size / 2
	
	call_deferred("update_current_room")

func _physics_process(delta):
	if is_moving:
		return

	# Check for input
	var input_vector = Vector2.ZERO
	for action in input_actions.keys():
		if Input.is_action_pressed(action):
			input_vector += input_actions[action]
	input_vector = input_vector.normalized()

	if input_vector != Vector2.ZERO:
		move_direction = input_vector
		move()

func _unhandled_input(event):
	if event.is_action_pressed("use_stairs"):
		if on_stair_tile == UP_STAIR_TILE_INDEX:
			emit_signal("stairs_up")
		elif on_stair_tile == DOWN_STAIR_TILE_INDEX:
			emit_signal("stairs_down")

func move():
	if is_moving:
		return

	# Setup the ray for collision detection
	var ray = player.get_node("RayCast2D")
	ray.target_position = move_direction * tile_size
	ray.force_raycast_update()

	# Check for collision
	if not ray.is_colliding():
		is_moving = true
		var target_position = player.position + move_direction * tile_size

		# Move the player to the next tile over time
		var tween = player.create_tween()
		tween.tween_property(player, "position", target_position, MOVE_TIME)
		tween.set_trans(Tween.TRANS_LINEAR)
		tween.set_ease(Tween.EASE_IN_OUT)
		tween.connect("finished", Callable(self, "_on_move_finished"))
	else:
		# Can't move; reset move_direction
		move_direction = Vector2.ZERO

func _on_move_finished():
	is_moving = false

	# Update tile position and emit signals
	var current_tile_pos = Vector2i(
		int(player.position.x / TILE_SIZE.x),
		int(player.position.y / TILE_SIZE.y)
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
	if tile_index == UP_STAIR_TILE_INDEX:
		on_stair_tile = UP_STAIR_TILE_INDEX
	elif tile_index == DOWN_STAIR_TILE_INDEX:
		on_stair_tile = DOWN_STAIR_TILE_INDEX
	else:
		on_stair_tile = -1

func update_current_room():
	var new_room = bsp_tree.get_room_at_position(player.position)
	if new_room != current_room:
		current_room = new_room
		if current_room != null:
			emit_signal("room_changed", current_room)
