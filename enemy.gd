class_name Enemy
extends CharacterBody2D


const max_health = 3
var health
# Called when the node enters the scene tree for the first time.
func _ready():
	var anim = $AnimatedSprite2D.sprite_frames.get_animation_names()
	$AnimatedSprite2D.play(anim[0])
	health = max_health


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	# move the character back and forth
	# position.x += 0.1
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
