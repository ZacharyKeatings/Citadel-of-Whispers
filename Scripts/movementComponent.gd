extends Component

class_name MovementComponent

var speed: float = 200

func initialize(speed_value: float):
	speed = speed_value

func update(delta: float):
	handle_input(delta)

func handle_input(delta: float):
	var velocity = Vector2()

	if Input.is_action_pressed("ui_right"):
		velocity.x += 1
	if Input.is_action_pressed("ui_left"):
		velocity.x -= 1
	if Input.is_action_pressed("ui_down"):
		velocity.y += 1
	if Input.is_action_pressed("ui_up"):
		velocity.y -= 1

	velocity = velocity.normalized() * speed * delta
	get_parent().position += velocity
