extends Component

class_name HealthComponent

var max_health: int = 100
var health: int = 100

func initialize(health_value: int, max_health_value: int):
	health = health_value
	max_health = max_health_value

func take_damage(amount: int):
	health = max(health - amount, 0)
	if health == 0:
		print("Player is dead")

func heal(amount: int):
	health = min(health + amount, max_health)
