extends RigidBody3D

@export var input_tracking_delay : float = 0.2
@export var speed_ratio : float = 1
@export var max_velocity : float = 50
@export var max_velocity_on_floor : float = 15
@export var input_treshold : float = 10

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
var handling_movement : bool = true

func get_look_vector() -> Vector3:
	var target_look : Node3D = get_tree().current_scene.get_node('Goal/Pivot')
	var target_origin : Vector3 = target_look.transform.origin
	return target_origin

func _physics_process(delta : float):
	var diff = current_pos - first_pos
	movement = Vector3(diff.x, -0.1, diff.y) * speed_ratio
	movement = movement.rotated(Vector3(0, 1, 0).normalized(), pivot.rotation.y)
	movement.normalized()
	
	linear_velocity = linear_velocity.limit_length(max_velocity)
	
	if raycast.is_colliding():
		movement = movement.limit_length(max_velocity_on_floor)
		angular_damp = 2
		linear_damp = 4
		if first_pos != Vector2(0, 0) and handling_movement:
			linear_velocity = movement
	else:
		angular_damp = 0
		linear_damp = 0
	
	var relative_velocity = linear_velocity.rotated(Vector3(0, 1, 0).normalized(), pivot.rotation.y)
	var lerped = lerp(camera.fov, -relative_velocity.z * 4, delta )
	camera.fov = clamp(lerped, 75, 100)

func _on_shoot_timeout():
	can_shoot = true

func _ready():
	var goal_area : Area3D = get_tree().current_scene.get_node('Goal/GoalArea')
	goal_area.body_entered.connect(_on_goal_area_body_entered)
	
	var game_area : Area3D = get_tree().current_scene.get_node('GameArea')
	game_area.body_exited.connect(_on_game_area_body_exited)
	
	input_tracking_timer.wait_time = input_tracking_delay
	input_tracking_timer.one_shot = true
	input_tracking_timer.timeout.connect(_on_shoot_timeout)
	add_child(input_tracking_timer)

func _process(delta : float):
	pivot.look_at(get_look_vector(), Vector3.UP)

func _input(event : InputEvent):
	if event is InputEventMouseButton and handling_movement == true:
		if event.is_pressed():
			current_pos = event.position
			first_pos = event.position
		if event.is_released():
			var diff : Vector2 = current_pos - first_pos
			var impulse_up = abs(diff.y) / 20 if (diff.y < 0 and raycast.is_colliding()) else 0
			var impulse = Vector3(diff.x / 8, impulse_up, diff.y / 3 if raycast.is_colliding() else 0 )
			impulse = impulse.rotated(Vector3(0, 1, 0).normalized(), pivot.rotation.y)
			apply_impulse(impulse ,Vector3(0, 0, 0))
			first_pos = Vector2(0, 0)
	
	if event is InputEventMouseMotion and handling_movement == true:
		current_pos = event.position
		if first_pos != Vector2(0, 0) and can_shoot:
			var diff = current_pos - first_pos
			var threshold = viewport_size / input_treshold
			first_pos = current_pos - (diff.clamp(-threshold, threshold))
			can_shoot = false
			input_tracking_timer.start()

func thread_vibration():
	for i in range(0, 1000):
		Input.vibrate_handheld(7)

func _on_goal_area_body_entered(body):
	if body == self and UI.lose.visible == false:
		UI.win.show()
		var thread = Thread.new()
		thread.start(thread_vibration.bind())
		
		handling_movement = false

func _on_game_area_body_exited(body):
	if body == self and UI.win.visible == false:
		UI.lose.show()
		handling_movement = false
