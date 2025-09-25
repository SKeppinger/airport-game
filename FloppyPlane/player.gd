extends CharacterBody2D
signal hit
var screen_size

const grav = 500
const JUMP_VELOCITY = -100.0

func _ready() -> void:
	screen_size = get_viewport_rect().size
	start(screen_size/2)
	pass # Replace with function body.


func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity.y += grav * delta
	else:
		hide() # Player disappears after being hit.
		hit.emit()
		# Must be deferred as we can't change physics properties on a physics callback.
		$CollisionShape2D.set_deferred("disabled", true)

	# Handle jump.
	if Input.is_action_pressed("button_a") or Input.is_action_pressed("move_up"):
		velocity.y = JUMP_VELOCITY

	move_and_slide()


func start(pos):
	position = pos
	show()
	$CollisionShape2D.disabled = false

func _on_body_entered(body: Node2D) -> void:
	hide() # Player disappears after being hit.
	hit.emit()
	# Must be deferred as we can't change physics properties on a physics callback.
	$CollisionShape2D.set_deferred("disabled", true)
