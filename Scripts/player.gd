extends Area2D
class_name Player

signal tile_changed(new_tile_pos)
signal room_changed(room)
signal stairs_up
signal stairs_down

# Reference to movement component
var movement_component: PlayerMovementComponent

func _ready():
	# Get reference to BSPTree
	var bsp_tree = get_parent() as BSPTree

	# Initialize the movement component
	movement_component = PlayerMovementComponent.new(self, bsp_tree)
	add_child(movement_component)

	# Connect signals from the movement component to player signals
	movement_component.connect("tile_changed", Callable(self, "_on_tile_changed"))
	movement_component.connect("room_changed", Callable(self, "_on_room_changed"))
	movement_component.connect("stairs_up", Callable(self, "_on_stairs_up"))
	movement_component.connect("stairs_down", Callable(self, "_on_stairs_down"))

func _physics_process(delta):
	# Delegate physics processing to movement component
	movement_component._physics_process(delta)

func _unhandled_input(event):
	# Delegate input handling to movement component
	movement_component._unhandled_input(event)

# Signal handlers
func _on_tile_changed(new_tile_pos):
	# Re-emit the signal
	emit_signal("tile_changed", new_tile_pos)

func _on_room_changed(room):
	# Re-emit the signal
	emit_signal("room_changed", room)

func _on_stairs_up():
	# Re-emit the signal
	emit_signal("stairs_up")

func _on_stairs_down():
	# Re-emit the signal
	emit_signal("stairs_down")
