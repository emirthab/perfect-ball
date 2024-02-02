extends Control

func _ready():
	GameManager.on_game_state_changed.connect(on_game_state_changed)

func _on_replay_pressed():
	GameManager.restart_level()

func on_game_state_changed(game_state : GameManager.GameState):
	match game_state:
		GameManager.GameState.Lose:
			$Lose.show()
		GameManager.GameState.Win:
			$Win.show()
		GameManager.GameState.Initial:
			$Lose.hide()
			$Win.hide()
			$Initial.show()
		GameManager.GameState.Playing:
			$Initial.hide()

func _on_tap_screen(event):
	if event is InputEventMouseButton:
		GameManager.set_game_state(GameManager.GameState.Playing)
