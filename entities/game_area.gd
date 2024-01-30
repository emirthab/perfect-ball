extends Area3D

func _ready():
	body_exited.connect(_on_body_exited)

func _on_body_exited(body):
	if body.is_in_group("player"):
		UI.lose.show()
