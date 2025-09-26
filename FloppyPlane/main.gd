extends Node
@export var obstacle_scene: PackedScene

var state

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	new_game()
	spawn_new()
	state = "play"


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_player_hit() -> void:
	game_over()

func game_over():
	if state == "play":
		state = "lose"
		print("Game Over")
	
func win():
	if state == "play":
		state = "win"
		print("Win")
	
func new_game():
	$player.start($StartPosition.position)
	$WinTimer.start()

func spawn_new():
	var obs = obstacle_scene.instantiate()
	
	var obs_spawn_location = $SpawnPath/SpawnLocation
	obs_spawn_location.progress_ratio = randf()
	
	obs.position = obs_spawn_location.position
	
	add_child.call_deferred(obs)
	

func _on_child_exiting_tree(node: Node) -> void:
	if node is obstacle:
		spawn_new()


func _on_win_timer_timeout() -> void:
	win()
