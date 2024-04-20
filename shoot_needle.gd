extends Node2D

const SPEED = 30
var flying = false
var hooked = false
var direction = Vector2(0,0)
var tip = Vector2(0,0)

var initial_position = Vector2(0,0)
const MAX_DISTANCE = 500
const MIN_DISTANCE = 1

const DMG_ON_HIT = 1

var collision = null

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
	
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	self.visible = flying or hooked
	if not self.visible:
		return
	var local_tip = to_local(tip)
	$Thread.rotation = self.position.angle_to_point(local_tip) + deg_to_rad(90)
	$Needle.rotation = self.position.angle_to_point(local_tip) + deg_to_rad(90)
	$Thread.position = local_tip
	$Thread.region_rect.size.y = local_tip.length()
	# if hooked:
		# print("Hooked!")

func _physics_process(delta):
	$Needle.global_position = tip
	if flying:
		collision = $Needle.move_and_collide(direction * SPEED)
		if collision:
			is_hooked.emit()
			hooked = true
			flying = false
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
	shoot(-direction)
	

func _on_area_2d_area_entered(area):
	if area.is_in_group("enemy"):
		var enemy = area.get_parent()
		var pos = enemy.global_position
		enemy.get_hit(DMG_ON_HIT)
		if not enemy.is_dead():
			print("hit")
			_bounce()
		else:
			print("Enemy pos", enemy.global_position)
			shoot(direction)
			print("killed")
		print("Enemy collided")
