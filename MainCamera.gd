extends Camera2D

const _DST_X = 15.0
const _DST_Y = 5.0
var dst_x 
var dst_y 
var epsilon = 0.1
var going_to_move = false
var stopwatch = 0.0
const CAMERA_SHIFT = 75
# Called when the node enters the scene tree for the first time.
var tween

var update_camera_offset = false

func _set_new_target_point():
	_generate_next_target()
	tween = create_tween()
	tween.tween_property($".", "position", Vector2(dst_x, dst_y), 1)
	tween.tween_interval(1.5)
	tween.tween_property($".", "position", Vector2(0,0), 1)
	tween.tween_interval(1.5)
	tween.tween_callback(_set_new_target_point)
	

func _generate_next_target():
	var _x = randi_range(-4, 4) / 4.0
	var _y = randi_range(-4, 4) / 4.0
	dst_x = _DST_X * _x
	dst_y = _DST_Y * _y

func _ready():
	_generate_next_target()
	tween = create_tween()
	tween.tween_property($".", "position", Vector2(dst_x, dst_y), 1)
	tween.tween_interval(1.5)
	tween.tween_property($".", "position", Vector2(0,0), 1)
	tween.tween_interval(1.5)
	tween.tween_callback(_set_new_target_point)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if update_camera_offset:
		offset.x = lerp(offset.x, 0-get_local_mouse_position().normalized().x * CAMERA_SHIFT, delta * 2)
		offset.y = lerp(offset.y, 0-get_local_mouse_position().normalized().y * CAMERA_SHIFT, delta * 2)
	



func _on_player_going_to_move():
	print("going to move!")
	going_to_move = true
	update_camera_offset=true
	tween.stop()



func _on_player_going_to_stop():
	print("STOP!")
	going_to_move = false
	update_camera_offset = false
	tween.stop()
	tween = create_tween().set_ease(Tween.EASE_IN)
	tween.tween_property($".", "offset", Vector2.ZERO, 0.5)
	tween.tween_interval(1.0)
	tween.tween_callback(_set_new_target_point)
	
	
