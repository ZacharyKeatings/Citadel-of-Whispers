extends Node2D

class_name Entity

var entity_name: String = "Default"
var components = {}

# Initialize the entity with basic data
func initialize(data: Dictionary):
	entity_name = data.get("name", "Unknown")

# Add a component to the entity
func add_component(component_name: String, component: Component):
	components[component_name] = component
	add_child(component)

# Get a component by name
func get_component(component_name: String) -> Component:
	return components.get(component_name, null)

# Remove a component
func remove_component(component_name: String):
	var component = components.get(component_name, null)
	if component:
		remove_child(component)
		components.erase(component)

# Update all components
func update_components(delta):
	for component in components.values():
		component.update(delta)
