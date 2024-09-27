extends Node2D

class_name Entity

var entity_name: String = "Default"
var description: String = ""

var components = {}
var collision_layer: int
var collision_mask: int

func _ready():
	pass

# Method to initialize the entity with basic data
func initialize(data: Dictionary):
	entity_name = data.get("name", "Unknown")
	description = data.get("description", "No description available")
	print("Entity initialized with name: ", entity_name, " and description: ", description)

func add_component(component_name: String, component: Node):
	components[component_name] = component
	add_child(component)

func get_component(component_name: String) -> Node:
	return components.get(component_name, null)
	
