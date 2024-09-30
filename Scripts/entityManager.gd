extends Node

class_name EntityManager

var entities = []

# Adding entities to the manager
func add_entity(entity: Entity):
	entities.append(entity)
	add_child(entity)

# Removing entities and cleaning up
func remove_entity(entity: Entity):
	entities.erase(entity)
	entity.queue_free()

# Updating all entities and their components
func update_entities(delta):
	for entity in entities:
		entity.update_components(delta)
