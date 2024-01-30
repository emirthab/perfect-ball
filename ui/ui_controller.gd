extends Control

@onready var lose : Control = $Lose
@onready var win : Control = $Win
@onready var initial : Control = $Initial

func _process(delta):
	pass

func _input(event):
	if event is InputEventMouseButton:
		initial.hide()
	# Debug
	if event.is_action_pressed("restart"):
		get_tree().reload_current_scene()
		lose.hide()
		initial.show()
	
func _on_replay_pressed():
	get_tree().reload_current_scene()
	lose.hide()
	win.hide()
	initial.show()
