extends Node

class_name Component

var owner_entity: Entity  # Reference to the entity that owns this component

# Called when the component is added to the scene
func _ready():
	owner_entity = get_parent() as Entity

# Update method to be overridden by specific components
func update(delta):
	pass
