extends Control

func _ready():
	GameManager.on_game_state_changed.connect(on_game_state_changed)
	GameManager.on_game_config_changed.connect(on_game_config_changed)

func _on_replay_pressed():
	GameManager.restart_level()

func on_game_state_changed(game_state : GameManager.GameState):
	match game_state:
		GameManager.GameState.Lose:
			$Lose.show()
			$LoseSfx.play()
		GameManager.GameState.Win:
			$Win.show()
			$WinSfx.play()
		GameManager.GameState.Initial:
			$Lose.hide()
			$Win.hide()
			$Initial.show()
		GameManager.GameState.Playing:
			$Initial.hide()
			$WhistleSfx.play()

func _on_tap_screen(event):
	if event is InputEventMouseButton:
		GameManager.set_game_state(GameManager.GameState.Playing)

func on_game_config_changed(config : Dictionary):
	$Settings/Window/Sounds.text = "Sounds : " + ("ON" if config["sounds_enabled"] else "OFF")
	$Settings/Window/Vibration.text = "Vibration : " + ("ON" if config["vibrations_enabled"] else "OFF")

func _toggle_vibration_settings():
	GameManager.set_game_config("vibrations_enabled", not GameManager.game_config["vibrations_enabled"])

func _toggle_sounds_settings():
	GameManager.set_game_config("sounds_enabled", not GameManager.game_config["sounds_enabled"])

func _on_close_settings_pressed():
	$Settings.hide()

func _on_settings_button_pressed():
	$Settings.show()
