class_name EnemyIdleState
extends State

@export var actor : Enemy
@export var animator : AnimatedSprite2D



func _enter_state() -> void:
	animator.play("idle")
	actor.velocity = Vector2.ZERO

func _exit_state() -> void:
	pass
	
