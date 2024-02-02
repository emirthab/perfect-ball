extends CharacterBody3D
class_name Enemy

enum HeadCosmetic { Helmet }

@export var enemy_level : int = 1

@export var kick_power_vertical : float = 10
@export var kick_power_horizontal : float = 50
@export var speed : float = 1
@export var inactive_wait_time : float = 0.76
@export var dash_speed : float = 3

@onready var player : Node3D = GameManager.get_player()
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
	if not inactive and tracking:
		look_at(-direction + global_transform.origin, Vector3.UP)
		move_and_collide(direction * speed * delta)


func _on_dash_area_body_entered(body):
	if body is Player and not is_dead:
		state_machine.travel("Slide")
		speed = dash_speed
		death()
		inactive_timer.start()


func _on_tracking_area_body_entered(body):
	if body is Player and not is_dead:
		state_machine.travel("Run")
		tracking = true

func _on_tocuh_area_body_entered(body):
	# Todo Clean
	# Havada maksimum 3 kere sağa sola çekebilsin
	# Yere inene kadar maksimum sağ sol yapma sıfırlanmasın
	if body is Player and not inactive:
		body.handling_movement = false
		var player_new_velocity = direction.normalized() * kick_power_horizontal
		player_new_velocity.y = kick_power_vertical
		body.linear_velocity = player_new_velocity
		await get_tree().create_timer(0.2).timeout
		body.handling_movement = true

func _inactive_timer_timeout():
	inactive = true

func death():
	is_dead = true
