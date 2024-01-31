extends Control

@onready var lose : Control = $Lose
@onready var win : Control = $Win
@onready var initial : Control = $Initial

func _process(delta):
	if get_tree().current_scene:
		var player = get_tree().current_scene.get_node("Player/Body")
		$ColorRect.position = player.first_pos
		$ColorRect2.position = player.current_pos

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
