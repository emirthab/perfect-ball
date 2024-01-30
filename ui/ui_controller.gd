extends Control

func _process(delta):
	pass

func _input(event):
	if event is InputEventMouseButton:
		$BeforeGame.hide()
	# Debug
	if event.is_action_pressed("restart"):
		get_tree().reload_current_scene()
