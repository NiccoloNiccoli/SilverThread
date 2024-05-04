extends Node2D

var v_offset = 32 * 21
var height = 10
const STD_ASPECT_RATIO = 9.0/16.0
const SHORT_SIDE = 360 #pixels
var long_side = 0
# Called when the node enters the scene tree for the first time.
func _ready():
	# get_viewport().size = DisplayServer.screen_get_size()
	# $DebugText.add_text(str(get_viewport().content_scale_size) + " " + str(DisplayServer.screen_get_size()) + " " + str(DisplayServer.window_get_size()))
	var window_size = DisplayServer.window_get_size() * 1.0
	var aspect_ratio = window_size[0]/window_size[1]
	long_side =  SHORT_SIDE/aspect_ratio
	print("Short side ",SHORT_SIDE," x Long side ", long_side," : aspect ratio ",aspect_ratio)
	# $DebugText.add_text(str(SHORT_SIDE) + " x " + str(long_side))
	get_viewport().content_scale_size = Vector2(SHORT_SIDE, long_side)
	print("Viewport ", get_viewport().content_scale_size)
	var _hub = load("res://Rooms/hub.tscn")
	var hub = _hub.instantiate()
	hub.position.x = 0
	hub.position.y = 0
	print(hub.position)
	add_child(hub)
	var pos = hub.get_player_spawn_position()
	get_node("player").position.x = hub.position.x + pos.x * 32
	get_node("player").position.y = hub.position.y + pos.y * 32
	# hub.propagate(false)
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass



