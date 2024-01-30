extends CharacterBody3D

@export var kick_power_vertical : float = 25
@export var kick_power_horizontal : float = 100
@export var speed : float = 1
@export var inactive_wait_time : float = 1
@export var dash_speed : float = 3

@onready var player : Node3D = get_tree().get_nodes_in_group("player")[0]
@onready var state_machine : AnimationNodeStateMachinePlayback = $AnimationTree["parameters/playback"]

var is_dead : bool = false
var tracking : bool = false
var inactive : bool = false
var inactive_timer : Timer = Timer.new()
var direction : Vector3

func _ready():
	inactive_timer.wait_time = inactive_wait_time
	inactive_timer.one_shot = true
	inactive_timer.timeout.connect(_inactive_timer_timeout)
	add_child(inactive_timer)
	

func _physics_process(delta):
	if !is_on_floor():
		move_and_collide(Vector3(0, -0.1, 0))
	if tracking and not is_dead:
		direction = player.global_transform.origin - global_transform.origin
		direction.y = -0.01
	if not inactive:
		look_at(-direction + global_transform.origin, Vector3.UP)
		move_and_collide(direction * speed * delta)


func _on_dash_area_body_entered(body : RigidBody3D):
	if body.is_in_group("player") and not is_dead:
		state_machine.travel("Slide")
		speed = dash_speed
		death()
		inactive_timer.start()


func _on_tracking_area_body_entered(body : RigidBody3D):
	if body.is_in_group("player") and not is_dead:
		state_machine.travel("Run")
		tracking = true

func _inactive_timer_timeout():
	inactive = true

func death():
	is_dead = true

func _on_tocuh_area_body_entered(body : RigidBody3D):
	if body.is_in_group("player") and not inactive:
		body.handling_movement = false
		var player_new_velocity = direction.normalized() * kick_power_horizontal
		player_new_velocity.y = kick_power_vertical
		body.linear_velocity = player_new_velocity
		await get_tree().create_timer(0.2).timeout
		body.handling_movement = true
