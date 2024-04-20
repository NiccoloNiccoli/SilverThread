class_name EnemyWalkState
extends State

@export var actor : Enemy
@export var animator : AnimatedSprite2D
@export var speed : int
@export var GRAVITY : int
@export var range : int
var p0 : Vector2

func _ready():
	pass

func _enter_state() -> void:
	# animator.play("walk")
	p0 = actor.position
	actor.velocity = Vector2.RIGHT * speed + Vector2.DOWN * GRAVITY

func _exit_state() -> void:
	pass

func _physics_process(_delta):
	# FIXME enemy is not affected by grtavity :|
	actor.move_and_slide()
	if p0.distance_to(actor.position) > range:
		actor.velocity = -actor.velocity
		animator.flip_h = not animator.flip_h
		p0 = actor.position
