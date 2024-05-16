extends Camera2D

var dst_x = 10.0
var dst_y = 5.0
var epsilon = 0.1
var going_to_move = false
var stopwatch = 0.0
const CAMERA_SHIFT = 150
# Called when the node enters the scene tree for the first time.
func _ready():
	dst_x *= 1 if randf() < 0.5 else -1
	dst_y *= 1 if randf() < 0.5 else -1


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	stopwatch += delta
	if going_to_move and stopwatch > 0.5:
		if abs(offset.x - dst_x) < epsilon:
			dst_x *= -1
		if abs(offset.y - dst_y) < epsilon:
			dst_y *= -1
		offset.x = lerp(offset.x, 0 - get_local_mouse_position().normalized().x * CAMERA_SHIFT, delta * 2)
		offset.y = lerp(offset.y, 0 - get_local_mouse_position().normalized().y * CAMERA_SHIFT, delta * 2)
		print(stopwatch)
	else:
		if abs(offset.x - dst_x) < epsilon:
			dst_x *= -1
		if abs(offset.y - dst_y) < epsilon:
			dst_y *= -1
		offset.x = lerp(offset.x, 0 + dst_x, delta)
		offset.y = lerp(offset.y, 0 + dst_y, delta)
	



func _on_player_going_to_move():
	print("going to move!")
	going_to_move = true
	stopwatch = 0
	



func _on_player_going_to_stop():
	print("STOP!")
	going_to_move = false
