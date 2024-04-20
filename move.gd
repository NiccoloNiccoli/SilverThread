extends Node2D

var speed = 1200
const threshold := 30
var pressedPos : Vector2
var releasedPos : Vector2
var player
var dir:=Vector2.ZERO
var can_move_again := true
var collision = null
var line = null
var clicks = 0
var start_point = null
var is_line_instantiated = false

const dmg_on_hit = 1

var _last_direction
var _last_angle
var rng = RandomNumberGenerator.new()

const THREAD_PULL = 500
var velocity = Vector2(0,0)
var thread_velocity = Vector2(0,0)

var press_tap_position = Vector2(0,0)
var release_tap_position = Vector2(0,0)
var swipe_direction = Vector2(0,0)

var swipe_shoot = false
var swipe_shoot_speed_increment = 1.0

const MAX_SPEED_UP_DUE_TO_SWIPE = 2.0
@onready var ray_cast_2d = $RayCast2D
@onready var big_collision_shape = $BigCollisionShape
@onready var small_collision_shape = $SmallCollisionShape

func _ready():
	player = get_node(".")
	line = Line2D.new() # Create a new Line2D node
	line.default_color = Color(1,0,0,1)
	add_child(line) # Add it as a child of the current node
	is_line_instantiated = true
	small_collision_shape.disabled = true
	big_collision_shape.disabled = false
	
func _draw():
	var v = Vector2(112, 216)
	draw_circle(v, 30, Color(1,0,0,0.5))
	

func _input(event : InputEvent) -> void:
	if Input.is_action_just_pressed("click"):
		press_tap_position = event.position
	if Input.is_action_just_released("click"):
		release_tap_position = event.position
		big_collision_shape.disabled = true
		small_collision_shape.disabled = false
		if press_tap_position.distance_to(release_tap_position) < 30:
			print("Tap")
			$Needle.shoot(event.position - get_viewport().content_scale_size * 0.5)	
			print(press_tap_position, release_tap_position)
		else:
			print("Swipe")
			swipe_direction = release_tap_position - press_tap_position
			# XXX must speed up the needle with longer swipes (do it better)
			swipe_shoot_speed_increment = clamp(sqrt(swipe_direction.dot(swipe_direction)) / 1e2, 1.0, MAX_SPEED_UP_DUE_TO_SWIPE)
			$Needle.stronger_shoot(-swipe_direction, swipe_shoot_speed_increment)
			swipe_shoot = true
			print(swipe_shoot_speed_increment)
			print(press_tap_position, release_tap_position)
			print(swipe_direction)
			
	if false:
		if Input.is_action_just_pressed("click"):
				pressedPos = event.position
				start_point = pressedPos - player.position
				$DirArrow.shoot(event.position)
				print("Me ", player.position, " Click ", event.position)
		if Input.is_action_pressed("click"):
				$DirArrow.shoot(event.position - get_viewport().content_scale_size * 0.5)
				pass
		if false:
			if Input.is_action_just_released("click"):
				releasedPos = event.position
				if can_move_again:
					for child in get_children():
						if child is Line2D:
							child.queue_free()
					is_line_instantiated = false
				calculate_gesture()
			
						
		if Input.is_action_just_released("click"):
			$DirArrow.release()
			$Needle.shoot(event.position - get_viewport().content_scale_size * 0.5)	
			print("Me ", player.position, " Click ", event.position)

func discretize_direction(start, end) -> Vector2:
	var direction = (end-start).normalized()
	var angle = atan2(direction.y, direction.x)
	var quantized_angle = round(angle / (PI/4)) * (PI/4)
	
	var quantized_direction = Vector2(cos(quantized_angle), sin(quantized_angle))
	_last_direction = quantized_direction
	_last_angle = quantized_angle
	print(quantized_direction)
	return quantized_direction
	

func calculate_gesture() -> void:
	if can_move_again:
		var direction := discretize_direction(pressedPos, releasedPos)
		dir = direction.normalized() * speed
		player.velocity = dir
		can_move_again = false
	
func _process(_delta):
	ray_cast_2d.target_position = -get_local_mouse_position()
	queue_redraw()

func _physics_process(delta):
	collision = player.move_and_collide(player.velocity * delta)
	
	if collision:
		big_collision_shape.disabled = false
		small_collision_shape.disabled = true
		$Needle.release()
		swipe_shoot = false
		player.velocity = Vector2.ZERO
		can_move_again = true
		
	if $Needle.hooked:
		thread_velocity = to_local($Needle.tip).normalized() * THREAD_PULL
		if swipe_shoot:
			thread_velocity *= swipe_shoot_speed_increment
		player.velocity = thread_velocity

func _bounce():
	var rx = rng.randf_range(-0.1, 0.1)
	var ry = rng.randf_range(-0.1, 0.1)
	dir = Vector2(-cos(_last_angle), -sin(_last_angle)).normalized() * speed
	print("Bounce", _last_direction.y, rx, -_last_direction.x, ry)
	print("Dir", dir)
	player.velocity = dir
	can_move_again = false
	
func _substitute_enemy():
	dir = Vector2(cos(_last_angle), sin(_last_angle)).normalized() * speed
	print("sub")
	player.velocity = dir
	can_move_again = false

func _on_area_2d_area_entered(area):
	pass
	'''
	if area.is_in_group("enemy"):
		var enemy = area.get_parent()
		var pos = enemy.global_position
		enemy.get_hit(dmg_on_hit)
		if not enemy.is_dead():
			# _bounce()
			pass
		else:
			player.position = pos
			print("Player pos ", player.global_position)
		print("Enemy collided")
	'''
	
