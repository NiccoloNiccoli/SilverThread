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

func _ready():
	player = get_node(".")
	line = Line2D.new() # Create a new Line2D node
	line.default_color = Color(1,0,0,1)
	add_child(line) # Add it as a child of the current node
	is_line_instantiated = true
	
	

func _input(event : InputEvent) -> void:
	if Input.is_action_just_pressed("click"):
		pressedPos = event.position
		start_point = pressedPos - player.position
		if can_move_again:
			line = Line2D.new()
			line.default_color = Color(1,0,0,1)
			add_child(line)
			line.add_point(start_point)
			line.add_point(start_point)
			is_line_instantiated = true
	if Input.is_action_just_released("click"):
		releasedPos = event.position
		if can_move_again:
			for child in get_children():
				if child is Line2D:
					child.queue_free()
			is_line_instantiated = false
		calculate_gesture()
	if Input.is_action_pressed("click"):
		if can_move_again:
			if start_point != null and is_line_instantiated == true:
					line.set_point_position(1, event.position - player.position)
				
		

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
	
	
func _physics_process(delta):
	collision = player.move_and_collide(player.velocity * delta)
	if collision:
		player.velocity = Vector2.ZERO
		can_move_again = true
		

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
	if area.is_in_group("enemy"):
		var enemy = area.get_parent()
		var pos = enemy.global_position
		enemy.get_hit(dmg_on_hit)
		if not enemy.is_dead():
			_bounce()
		else:
			player.position = pos
			print("Player pos ", player.global_position)
		print("Enemy collided")
