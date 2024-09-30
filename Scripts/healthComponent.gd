extends Component

class_name HealthComponent

var max_health: int = 100
var current_health: int = 100

# Initialize health
func _ready():
	current_health = max_health

# Apply damage to the entity
func take_damage(amount: int):
	current_health -= amount
	if current_health <= 0:
		current_health = 0
		die()

# Heal the entity
func heal(amount: int):
	current_health += amount
	if current_health > max_health:
		current_health = max_health

# Handle entity death
func die():
	if owner_entity:
		print(owner_entity.entity_name + " has died.")
		owner_entity.queue_free()
