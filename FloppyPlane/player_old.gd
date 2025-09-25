extends CharacterBody2D
signal hit
@export var speed = 25
var screen_size

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	screen_size = get_viewport_rect().size
	start(screen_size/2)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var vel = Vector2(0, 1)
	if Input.is_action_pressed("button_a") or Input.is_action_pressed("move_up"):
		vel.y -= speed
	linear_velocity += vel*delta
	print(linear_velocity)
	
func start(pos):
	position = pos
	show()
	$CollisionShape2D.disabled = false

func _on_body_entered(body: Node2D) -> void:
	hide() # Player disappears after being hit.
	hit.emit()
	# Must be deferred as we can't change physics properties on a physics callback.
	$CollisionShape2D.set_deferred("disabled", true)
