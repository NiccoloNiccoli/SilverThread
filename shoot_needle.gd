extends Node2D

const SPEED = 70

var flying = false
var hooked = false
var direction = Vector2(0,0)
var tip = Vector2(0,0)

var initial_position = Vector2(0,0)
const MAX_DISTANCE = 500
const MIN_DISTANCE = 1

const DMG_ON_HIT : float = 1.0
const CRIT_MULT : float = 3.0

var collision = null

@onready var raycast = $Needle/RayCast
@onready var backraycast = $Needle/BackRayCast

signal is_hooked

func shoot(dir:Vector2)->void:
	flying = true
	direction = dir.normalized()
	tip = self.global_position
	initial_position = self.global_position
	hooked = false

func stronger_shoot(dir:Vector2, speed_buff:float)->void:
	flying = true
	direction = dir.normalized() * speed_buff
	tip = self.global_position
	initial_position = self.global_position
	hooked = false
	
func release():
	flying = false
	hooked = false
	# $Needle/CollisionShape2D.disabled = true
	# $Needle/SmallCollisionShape2D2.disabled = true
	
# Called when the node enters the scene tree for the first time.
func _ready():
	self.visible = true
	$Needle/CollisionShape2D.disabled = true
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	self.visible = flying or hooked
	if not self.visible:
		return
	if raycast.is_colliding() and not backraycast.is_colliding():
		$Needle/CollisionShape2D.disabled = false
	var local_tip = to_local(tip)
	$Thread.rotation = self.position.angle_to_point(local_tip) + deg_to_rad(90)
	$Needle.rotation = self.position.angle_to_point(local_tip) + deg_to_rad(90)
	$Thread.position = local_tip
	$Thread.region_rect.size.y = local_tip.length()
	if hooked:
		$Needle/CollisionShape2D.disabled = true

func _physics_process(delta):
	$Needle.global_position = tip
	if flying:
		collision = $Needle.move_and_collide(direction * SPEED)
		if collision:
			is_hooked.emit()
			hooked = true
			flying = false
			#$Needle/CollisionShape2D.disabled = true
			#$Needle/SmallCollisionShape2D2.disabled = false
	tip = $Needle.global_position
	# Distance mechanism
	if flying and tip.distance_to(initial_position) > MAX_DISTANCE:
		print("too far")
		release()
	if tip.distance_to(initial_position) < MIN_DISTANCE:
		release()

func _bounce():
	direction.x *= randf_range(0.8, 1.2)
	direction.y *= randf_range(0.8, 1.2)
	# is it useful?
	# shoot(-direction)
	

func _on_area_2d_area_entered(area):
	if area.is_in_group("enemy"):
		var enemy = area.get_parent()
		var pos = enemy.global_position
		if area.is_in_group("critarea"):
			enemy.get_hit(DMG_ON_HIT * CRIT_MULT)
			print("CRIT!")
		else:
			enemy.get_hit(DMG_ON_HIT)
		if not enemy.is_dead():
			print("hit")
			_bounce()
		else:
			print("Enemy pos", enemy.global_position)
			# shoot(direction)
			print("killed")
		print("Enemy collided")
	if area.is_in_group("player"):
		# $Needle/CollisionShape2D.disabled = true
		# hooked = false
		print("Pipip")
		
