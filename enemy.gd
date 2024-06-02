class_name Enemy
extends CharacterBody2D


const max_health = 3
var health

@onready var finite_state_machine = $FiniteStateMachine
@onready var enemy_idle_state = $FiniteStateMachine/EnemyIdleState
@onready var enemy_walk_state = $FiniteStateMachine/EnemyWalkState

# Called when the node enters the scene tree for the first time.
func _ready():
	var anim = $AnimatedSprite2D.sprite_frames.get_animation_names()
	$AnimatedSprite2D.play("Idle")
	health = max_health
	enemy_idle_state.go_walking.connect(finite_state_machine.change_state.bind(enemy_walk_state))
	enemy_walk_state.stop_walking.connect(finite_state_machine.change_state.bind(enemy_idle_state))


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass

func get_hit(dmg):
	health -= dmg
	print("Position ", position)
	if health <= 0:
		self.visible = false
		$CollisionShape2D.disabled = true
		queue_free()

func is_dead():
	if health > 0:
			return false
	else:
		return true

func _on_area_2d_area_entered(_area):
	pass
