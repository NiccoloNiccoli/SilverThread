extends CharacterBody2D

# ----------------- General Variables -----------------
@export var speed = 1000
const threshold := 30 
var player
@export var use_swipe : bool = true # FIXME if true, the player will shoot the needle with a swipe, otherwise with a tap

# ----------------- Sprite -----------------
@onready var sprite_torso = $PlayerSprite/Torso
@onready var sprite_head = $PlayerSprite/Torso/Head
@onready var sprite_arm_front = $PlayerSprite/Arm_Front
@onready var sprite_arm_back = $PlayerSprite/Arm_Back
@onready var sprite_leg_front = $PlayerSprite/Leg_Front
@onready var sprite_leg_back = $PlayerSprite/Leg_Back

# ----------------- Gesture Variables -----------------
var pressedPos : Vector2
var releasedPos : Vector2
var dir:=Vector2.ZERO
var can_move_again := true
var collision = null
var line = null
var clicks = 0
var start_point = null
var is_line_instantiated = false

# ----------------- Attack Variables -----------------
const dmg_on_hit = 1

var _last_direction
var _last_angle
var rng = RandomNumberGenerator.new()

# ----------------- Needle Variables -----------------
@onready var needle = $Needle
const THREAD_PULL = 500
var _velocity = Vector2(0,0)
var thread_velocity = Vector2(0,0)
var needle_starting_position = Vector2(0,0)
var needle_starting_rotation

var press_tap_position = Vector2(0,0)
var release_tap_position = Vector2(0,0)
var swipe_direction = Vector2(0,0)

var swipe_shoot = false
var swipe_shoot_speed_increment = 1.0

const MAX_SPEED_UP_DUE_TO_SWIPE = 1.0

# ----------------- Collision Shapes -----------------
@onready var big_body_collision_shape = $BigBodyCollider
@onready var big_head_collision_shape = $BigHeadCollider
@onready var small_collision_shape = $SmallCollider
@onready var collision_raycast = $CollisionIncomingRaycast

# ----------------- Managing direction indicator -----------------
@onready var dir_arrow = $DirectionIndicator/LittleArrow
var is_going_to_move = false
@onready var little_balls_container = $DirectionIndicator/LittleBallsContainer
const LITTLE_BALL_DISTANCE = 30 # pixels between two little balls
const MAX_LITTLE_BALLS = 10
var distance_player_to_mouse = 0
var _old_n_displayer_balls = 0
var n_displayed_balls = 0
const BALLS_FROM_PLAYER_OFFSET = 2 # how many "little_ball_distance"s the first visible ball is


signal going_to_move
signal going_to_stop

func _ready():
	player = get_node(".")

	_set_body_collider(true)

	for i in range(MAX_LITTLE_BALLS):
		var sprite = Sprite2D.new()
		sprite.texture = preload("res://little_balls.png")
		sprite.visible = false
		little_balls_container.add_child(sprite)

	print("Little balls ", little_balls_container.get_children().size())
	
	
func _input(event : InputEvent) -> void:
	if Input.is_action_just_pressed("click"):
		press_tap_position = event.position
		is_going_to_move = true
		emit_signal("going_to_move")
	if Input.is_action_just_released("click"):
		is_going_to_move = false
		emit_signal("going_to_stop")
		release_tap_position = event.position
		_set_body_collider(false)
		if press_tap_position.distance_to(release_tap_position) < 10:
			print("Tap")
			needle.shoot(event.position - get_viewport().content_scale_size * 0.5)	
			print(press_tap_position, release_tap_position)
		else:
			print("Swipe")
			swipe_direction = release_tap_position - press_tap_position
			# XXX must speed up the needle with longer swipes (do it better)
			swipe_shoot_speed_increment = clamp(sqrt(swipe_direction.dot(swipe_direction)) / 1e2, 1.0, MAX_SPEED_UP_DUE_TO_SWIPE)
			needle.stronger_shoot(-swipe_direction, swipe_shoot_speed_increment)
			swipe_shoot = true
			print(swipe_shoot_speed_increment)
			print(press_tap_position, release_tap_position)
			print(swipe_direction)
		collision_raycast.target_position = -swipe_direction.normalized() * 45
		
		
			
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
			needle.shoot(event.position - get_viewport().content_scale_size * 0.5)	
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
	if collision_raycast.is_colliding():
		_set_body_collider(true)
	
	if is_going_to_move:
	
		# Setting up the arrow
		dir_arrow.visible = true
		dir_arrow.position = -get_local_mouse_position().normalized() * (4+2) * LITTLE_BALL_DISTANCE
		dir_arrow.rotation = dir_arrow.position.angle() + PI/2

		# Setting up the little balls
		distance_player_to_mouse = get_local_mouse_position().distance_to(Vector2.ZERO)
		# n_displayed_balls = floor(distance_player_to_mouse / LITTLE_BALL_DISTANCE) - BALLS_FROM_PLAYER_OFFSET
		# n_displayed_balls = clamp(n_displayed_balls, 0, MAX_LITTLE_BALLS)
		n_displayed_balls = 4
		if _old_n_displayer_balls > n_displayed_balls:
			for i in range(n_displayed_balls, _old_n_displayer_balls):
				var ball = little_balls_container.get_child(i)
				ball.visible = false
		little_balls_container.visible = true
		for i in range(n_displayed_balls):
			var ball = little_balls_container.get_child(i)
			ball.visible = true
			ball.position = dir_arrow.position.normalized() * ((i + BALLS_FROM_PLAYER_OFFSET) * LITTLE_BALL_DISTANCE)
		
		_old_n_displayer_balls = n_displayed_balls
	else:
		dir_arrow.visible = false
		
		if little_balls_container.visible:
			for i in range(n_displayed_balls):
				var ball = little_balls_container.get_child(i)
				ball.visible = false
			little_balls_container.visible = false
			
	queue_redraw()

func _physics_process(delta):
	collision = player.move_and_collide(player.velocity * delta)
	
	if collision:
		_set_body_collider(true)
		needle.release()
		swipe_shoot = false
		player.velocity = Vector2.ZERO
		can_move_again = true
		
	if needle.hooked:
		thread_velocity = to_local(needle.tip).normalized() * THREAD_PULL
		if swipe_shoot:
			thread_velocity *= swipe_shoot_speed_increment
		player.velocity = thread_velocity
		if player.velocity.x < 0:
			sprite_torso.flip_h = true
			sprite_head.flip_h = true
			sprite_arm_back.flip_h = true
			sprite_arm_front.flip_h = true
			sprite_leg_back.flip_h = true
			sprite_leg_front.flip_h = true
		else:
			sprite_torso.flip_h = false
			sprite_head.flip_h = false
			sprite_arm_back.flip_h = false
			sprite_arm_front.flip_h = false
			sprite_leg_back.flip_h = false
			sprite_leg_front.flip_h = false
			

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


# ----------------- Utility functions -----------------
func _set_body_collider(activate: bool) -> void:
	'''
		Activate or deactivate the big body collider and the small collider

		:param activate: bool
			True to activate the big body collider and deactivate the small collider
			False to deactivate the big body collider and activate the small collider
	'''
	big_body_collision_shape.disabled = !activate
	big_head_collision_shape.disabled = !activate
	small_collision_shape.disabled = activate
