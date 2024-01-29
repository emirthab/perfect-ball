extends Area3D

func _ready():
	body_exited.connect(_on_body_exited)

func _on_body_exited(body : RigidBody3D):
	if body.is_in_group("player"):
		get_tree().reload_current_scene()
