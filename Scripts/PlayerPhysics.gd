extends CharacterBody2D

#@onready var detect_area = $DetectArea
#@onready var collision_shape = $DetectArea/CollisionShape2D

func _ready():
	set_process_input(true)

func _physics_process(delta):
	move_and_slide()
	#pass
	
func _input(event):
	pass
