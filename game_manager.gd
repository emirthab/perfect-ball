extends Node

enum GameState { Initial, Lose, Win }

signal on_win
signal on_lose

var game_state : GameState = GameState.Initial : get = get_game_state, set = set_game_state
@onready var player = get_tree().current_scene.get_node("%Player")

func get_game_state() -> GameState:
	return game_state

func set_game_state(game_state : GameState):
	game_state = game_state

func get_player() -> Player:
	return player
