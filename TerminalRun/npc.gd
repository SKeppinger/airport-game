extends RigidBody2D
func _ready() -> void:
	#rn im just starting animations
	$AnimatedSprite2D.animation="walk"
	$AnimatedSprite2D.play()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_visible_on_screen_notifier_2d_screen_exited():
#LTGed as soon as it leaves the screen
	queue_free()
