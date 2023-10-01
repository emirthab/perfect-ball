extends RigidBody3D

@export var input_tracking_delay : float
@export var speed_ratio : float
@export var max_velocity : float
@export var input_treshold : float

@onready var raycast : RayCast3D = get_node('../Pivot/RayCast')
@onready var pivot : Node3D = get_node('../Pivot')
@onready var camera : Camera3D = get_node('../Pivot/Camera')
@onready var viewport_size : Vector2 = get_viewport().get_visible_rect().size

var input_tracking_timer : Timer = Timer.new()
var enemy : CharacterBody3D
var can_shoot : bool = true
var first_pos : Vector2 = Vector2(0, 0)
var current_pos : Vector2
var movement : Vector3

func get_look_vector() -> Vector3:
	var target_look : Node3D = get_tree().current_scene.get_node('Goal')
	var target_origin : Vector3 = target_look.transform.origin
	return target_origin

func _physics_process(delta : float):
	var pos_x : float = (current_pos.x - first_pos.x) * speed_ratio
	var pos_y : float = (current_pos.y - first_pos.y) * speed_ratio
	
	var pivot_rotation_y : float = pivot.rotation.y
	
	movement = Vector3(pos_x, 0, pos_y)
	movement = movement.rotated(Vector3(0, 1, 0).normalized(), pivot_rotation_y)
	movement.normalized()
	
	linear_velocity = linear_velocity.limit_length(100)
	
	if raycast.is_colliding():
		movement = movement.limit_length(10)
		angular_damp = 2
		linear_damp = 5
		if first_pos != Vector2(0, 0):
			linear_velocity = movement
	else:
		angular_damp = 0
		linear_damp = 0
	
	var relative_velocity = linear_velocity.rotated(Vector3(0, 1, 0).normalized(), pivot_rotation_y)
	var lerped = lerp(camera.fov, -relative_velocity.z * 4, delta )
	camera.fov = clamp(lerped, 75, 100)

func _on_shoot_timeout():
	can_shoot = true

func _ready():
	input_tracking_timer.wait_time = input_tracking_delay
	input_tracking_timer.one_shot = true
	input_tracking_timer.timeout.connect(_on_shoot_timeout)
	add_child(input_tracking_timer)

func _process(delta : float):
	pivot.look_at(get_look_vector(), Vector3.UP)

func _input(event : InputEvent):
	if event is InputEventMouseButton:
		if event.button_index == 1:
			if event.is_pressed():
				first_pos = event.position
			if not event.is_pressed():
				var diff = current_pos - first_pos
				var impulse_up = diff.y if diff.y < 0 else 0
				var impulse = Vector3(movement.x * abs(diff.x) / 80, impulse_up / 5, movement.z * abs(diff.y) / 40 )
				apply_impulse(impulse, Vector3(0, 0, 0))
				first_pos = Vector2(0, 0)
	
	if event is InputEventMouseMotion:
		current_pos = event.position
		if first_pos != Vector2(0, 0) and can_shoot:
			var diff = current_pos - first_pos
			var threshold = viewport_size / input_treshold
			first_pos = current_pos - (diff.clamp(-threshold, threshold))
			can_shoot = false
			input_tracking_timer.start()
