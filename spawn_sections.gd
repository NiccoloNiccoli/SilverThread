extends Node2D

var v_offset = 16 * 21
var height = 10
# Called when the node enters the scene tree for the first time.
func _ready():
	var _hub = load("res://Rooms/hub.tscn")
	var hub = _hub.instantiate()
	hub.position.x = 0
	hub.position.y = 0
	print(hub.position)
	add_child(hub)
	var pos = hub.get_player_spawn_position()
	get_node("player").position.x = hub.position.x + pos.x * 16
	get_node("player").position.y = hub.position.y + pos.y * 16
	
	hub.propagate(false)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass



