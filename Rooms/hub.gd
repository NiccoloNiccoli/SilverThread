extends Node2D

const block_height = 22 # FIXME
const tile_size = 32 # FIXME
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func get_player_spawn_position():
	return {"x": 0, "y":19}

func propagate(is_boss_room_existent, boss_chance = 0.0):
	# Instantiate other pieces
	var _v_corridor = load("res://Rooms/base_v_corridor.tscn")
	var v_corridor = _v_corridor.instantiate()
	v_corridor.position.x = 0
	v_corridor.position.y = -v_corridor.block_height * v_corridor.tile_size
	add_child(v_corridor)
	v_corridor.propagate(is_boss_room_existent)
	return is_boss_room_existent
	
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
