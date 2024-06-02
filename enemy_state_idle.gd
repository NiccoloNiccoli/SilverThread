class_name EnemyIdleState
extends State

@export var actor : Enemy
@export var animator : AnimatedSprite2D

signal go_walking

const WALKING_THRESHOLD = 0.2
const STOPWATCH_WALKING_THRESHOLD = 1.0 
var stopwatch = 0.0

func _enter_state() -> void:
	animator.play("Idle")
	actor.velocity = Vector2.ZERO
	set_process(true)

func _exit_state() -> void:
	set_process(false)
	
func _process(delta):
	stopwatch += delta
	if stopwatch > STOPWATCH_WALKING_THRESHOLD:	
		if randf_range(0,1) < WALKING_THRESHOLD:
			go_walking.emit()
			print("Time to walk!")
		stopwatch = 0.0
	
