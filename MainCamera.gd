extends Camera2D

var dst_x = 10.0
var dst_y = 5.0
var epsilon = 0.1
# Called when the node enters the scene tree for the first time.
func _ready():
	dst_x *= 1 if randf() < 0.5 else -1
	dst_y *= 1 if randf() < 0.5 else -1
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if abs(offset.x - dst_x) < epsilon:
		dst_x *= -1
	if abs(offset.y - dst_y) < epsilon:
		dst_y *= -1
	offset.x = lerp(offset.x, 0 + dst_x, delta)
	offset.y = lerp(offset.y, 0 + dst_y, delta)
	pass
