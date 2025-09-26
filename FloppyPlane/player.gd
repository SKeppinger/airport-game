extends CharacterBody2D
class_name player
signal hit
const grav = 500
const JUMP_VELOCITY = -150.0

var dead = false

func _ready() -> void:
	pass


func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity.y += grav * delta
	else:
		# hide() # Player disappears after being hit.
		hit.emit()
		dead = true
		# Must be deferred as we can't change physics properties on a physics callback.
		# $CollisionShape2D.set_deferred("disabled", true)

	# Handle jump.
	if (Input.is_action_just_pressed("button_a") or Input.is_action_just_pressed("move_up")) and not dead:
		velocity.y = JUMP_VELOCITY

	move_and_slide()


func start(pos):
	position = pos
	show()
	$CollisionShape2D.disabled = false


func _on_area_2d_area_entered(area: Area2D) -> void:
	if area is obstacle:
		hit.emit()
		dead = true
