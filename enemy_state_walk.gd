class_name EnemyWalkState
extends State

@export var actor : Enemy
@export var animator : AnimatedSprite2D
@export var speed : int
@export var GRAVITY : int
@export var range : int
var p0 : Vector2
@onready var ray_cast_ground_finder = $"../../RayCastGroundFinder"
@onready var ray_cast_wall_ahead = $"../../RayCastWallAhead"

var module : float = 0.5
var direction : Vector2 = Vector2.LEFT

var stopwatch = 0.0
const STOPWATCH_THRESHOLD = 3.0
const STOP_WALKING_THRESHOLD = 0.25

var critAreaPos : Vector2 = Vector2(8.5, -1.5) 
@onready var crit_collider_left = $"../../CritArea/CritColliderLeft"
@onready var crit_collider_right = $"../../CritArea/CritColliderRight"



signal stop_walking


func _ready():
	set_physics_process(false)

func _enter_state() -> void:
	animator.play("Move")
	set_physics_process(true)

func _exit_state() -> void:
	set_physics_process(false)

func _turn_back():
	direction *= -1
	ray_cast_wall_ahead.target_position.x *=-1
	ray_cast_ground_finder.target_position.x *= -1
	animator.flip_h = !animator.flip_h
	crit_collider_left.disabled = !crit_collider_left.disabled
	crit_collider_right.disabled != crit_collider_right.disabled
	
	
	
func _physics_process(_delta):
	stopwatch += _delta
	if stopwatch > 	STOPWATCH_THRESHOLD:
		stopwatch = 0.0
		if randf_range(0.0, 1.0) < STOP_WALKING_THRESHOLD:
			stop_walking.emit()
			print("Time to chill...")
			
	if ray_cast_ground_finder.is_colliding():
		actor.move_and_collide(module * direction)
	else:
		_turn_back()
	if ray_cast_wall_ahead.is_colliding():
		_turn_back()
		
