extends Control


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _input(event):
	if event.is_action_pressed("restart"):
		get_tree().reload_current_scene()

func _process(delta):
	$FirstPos.position = get_node("../Player/Body").first_pos
