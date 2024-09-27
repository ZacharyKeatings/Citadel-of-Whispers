extends Node

class_name EntityManager

var entities = []

func _ready():
	pass

func remove_entity(entity: Entity):
	entities.erase(entity)
	entity.queue_free()

func update_entities(delta):
	for entity in entities:
		for component in entity.components.values():
			component.update(delta)
