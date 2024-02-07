extends Node

enum GameState { Initial, Playing, Lose, Win, Loading }

var game_config : Dictionary  = {
	"sounds_enabled" : true,
	"vibrations_enabled" : true
}

func get_game_config() -> Dictionary:
	return game_config

func set_game_config(key : String, value):
	game_config[key] = value
	emit_signal("on_game_config_changed", game_config)
	
signal on_game_state_changed
signal on_game_config_changed

var game_state : GameState = GameState.Loading : get = get_game_state, set = set_game_state
func get_game_state() -> GameState:
	return game_state

func set_game_state(state : GameState):
	game_state = state
	emit_signal("on_game_state_changed", game_state)

func get_player():
	return get_tree().current_scene.get_node("%PlayerBehaviour/Player")

func get_goal() -> StaticBody3D:
	return get_tree().current_scene.get_node("%Goal")

func get_goal_pivot() -> Node3D:
	return get_tree().current_scene.get_node("%Goal/Pivot")

func get_goal_area() -> Area3D:
	return get_tree().current_scene.get_node("%Goal/GoalArea")

func get_game_area() -> Area3D:
	return get_tree().current_scene.get_node("%GameArea")

func connector():
	get_game_area().body_exited.connect(_on_game_area_body_exited)
	get_goal_area().body_entered.connect(_on_goal_area_body_entered)

func restart_level():
	set_game_state(GameState.Loading)
	get_tree().reload_current_scene()

func _ready():
	connector()
	set_game_state(GameState.Initial)
	get_tree().node_added.connect(_scene_ready)

func _on_game_area_body_exited(body):
	if body is Player and game_state == GameState.Playing:
		set_game_state(GameState.Lose)

func _on_goal_area_body_entered(body):
	if body is Player and game_state == GameState.Playing:
		set_game_state(GameState.Win)

func _scene_ready(node):
	# Scene changed or reloaded
	if node == get_tree().current_scene:
		connector()
		set_game_state(GameState.Initial)

func start_level(level : int):
	print(level)
	set_game_state(GameState.Loading)
	var _level = load("res://levels/level_%s.tscn" % str(level))
	get_tree().change_scene_to_packed(_level)

func get_current_level() -> int:
	return int(get_tree().current_scene.name.replace("Level ", ""))
