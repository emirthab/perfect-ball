extends RigidBody3D
class_name Player

@export var input_tracking_delay : float = 0.2
@export var speed_ratio : float = 1
@export var max_velocity : float = 50
@export var max_velocity_on_floor : float = 15
@export var input_treshold : float = 10
@export var minimum_kick_diff : float = 250

@onready var raycast : RayCast3D = get_node('../Pivot/RayCast')
@onready var pivot : Node3D = get_node('../Pivot')
@onready var camera : Camera3D = get_node('../Pivot/Camera')
@onready var viewport_size : Vector2 = get_viewport().get_visible_rect().size

@onready var bounce_sfx = preload("res://entities/player/sounds/bounce.tscn")
@onready var kick_sfx = preload("res://entities/player/sounds/kick.tscn")

var input_tracking_timer : Timer = Timer.new()
var enemy : CharacterBody3D
var can_shoot : bool = true
var first_pos : Vector2 = Vector2(0, 0)
var current_pos : Vector2
var movement : Vector3
var handling_movement : bool = true

func _physics_process(delta : float):
	pivot.look_at(GameManager.get_goal_pivot().transform.origin, Vector3.UP)
	if not handling_movement or GameManager.get_game_state() != GameManager.GameState.Playing:
		return
		
	var diff = current_pos - first_pos
	movement = Vector3(diff.x, -0.1, diff.y) * speed_ratio
	movement = movement.rotated(Vector3(0, 1, 0).normalized(), pivot.rotation.y)
	movement.normalized()
	
	linear_velocity = linear_velocity.limit_length(max_velocity)
	
	if raycast.is_colliding():
		physics_material_override.absorbent = true
		movement = movement.limit_length(max_velocity_on_floor)
		angular_damp = 2
		linear_damp = 4
		if first_pos != Vector2(0, 0) and handling_movement:
			linear_velocity = movement
	else:
		physics_material_override.absorbent = false
		angular_damp = 0
		linear_damp = 0
	
	var relative_velocity = linear_velocity.rotated(Vector3(0, 1, 0).normalized(), pivot.rotation.y)
	var lerped = lerp(camera.fov, -relative_velocity.z * 4, delta )
	camera.fov = clamp(lerped, 75, 100)

func _on_shoot_timeout():
	can_shoot = true

func _ready():
	input_tracking_timer.wait_time = input_tracking_delay
	input_tracking_timer.one_shot = true
	input_tracking_timer.timeout.connect(_on_shoot_timeout)
	add_child(input_tracking_timer)

func play_kick_sound():
	var sound = kick_sfx.instantiate()
	add_child(sound)
	sound.play()

func play_bounce_sound():
	var sound = bounce_sfx.instantiate()
	add_child(sound)
	sound.play()
	
func _input(event : InputEvent):
	if event is InputEventMouseButton:
		if event.is_pressed():
			current_pos = event.position
			first_pos = event.position
			
		if event.is_released() and GameManager.get_game_state() == GameManager.GameState.Playing:
			var diff : Vector2 = current_pos - first_pos
			var impulse_up = 0
			if -diff.y >= minimum_kick_diff and raycast.is_colliding():
				play_kick_sound()
				impulse_up = abs(diff.y) / 20 if diff.y < 0 else 0
			var impulse = Vector3(diff.x / 8, impulse_up, diff.y / 3 if raycast.is_colliding() else 0 )
			impulse = impulse.rotated(Vector3(0, 1, 0).normalized(), pivot.rotation.y)
			apply_impulse(impulse ,Vector3(0, 0, 0))
			first_pos = Vector2(0, 0)

	elif event is InputEventMouseMotion:
		current_pos = event.position
		if first_pos != Vector2(0, 0) and can_shoot:
			var diff = current_pos - first_pos
			var threshold = viewport_size / input_treshold
			first_pos = current_pos - (diff.clamp(-threshold, threshold))
			can_shoot = false
			input_tracking_timer.start()


func _on_bounce_area_body_entered(body):
	if (body is StaticBody3D or body is CSGShape3D) and GameManager.game_state != GameManager.GameState.Initial:
		play_bounce_sound()
