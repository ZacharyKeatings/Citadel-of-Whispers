extends Entity

# Player properties
#@onready var collision_shape = $CharacterBody2D/CollisionShape2D
#@onready var area = $CharacterBody2D

var username: String = "Default"
var gender: String = "Unknown"
var location: String = 'Forest'
var skill_bars = {}
var unlocked_skills = {}

# Called when the node enters the scene tree for the first time.
func _ready():
	z_index = 99
	
	var health_component = HealthComponent.new()
	health_component.initialize(100, 100)
	add_component("health", health_component)

	var movement_component = MovementComponent.new()
	movement_component.initialize(100)
	add_component("movement", movement_component)

# Update all components
func _process(delta):
	for component in components.values():
		component.update(delta)
		
# Method to get the health component
func get_health_component() -> HealthComponent:
	return get_component("health") as HealthComponent

# Method to access the player's max health
func get_current_health() -> int:
	var health_component = get_health_component()
	if health_component:
		return health_component.health
	return 0

# Method to access the player's max health
func get_max_health() -> int:
	var health_component = get_health_component()
	if health_component:
		return health_component.max_health
	return 0
