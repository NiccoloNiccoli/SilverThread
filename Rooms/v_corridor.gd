extends Node2D

const block_height = 21
const tile_size = 16
const max_increment = 0.3
var rng = RandomNumberGenerator.new()
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func propagate(is_boss_room_existent, boss_chance = 0.0):
	# Instantiate other pieces

	var r = rng.randf()
	print(r)
	if r < boss_chance and not is_boss_room_existent:
		# There is a boss
		var _boss_room = load("res://Rooms/boss_room.tscn")
		var boss_room = _boss_room.instantiate()
		boss_room.position.x = 0
		boss_room.position.y = -boss_room.block_height * boss_room.tile_size
		add_child(boss_room)
		boss_room.get_boss_position()
		print("Boss room created!")
		is_boss_room_existent = true
	else:
		# There is no boss
		var _v_corridor = load("res://Rooms/base_v_corridor.tscn")
		var v_corridor = _v_corridor.instantiate()
		v_corridor.position.x = 0
		v_corridor.position.y = -v_corridor.block_height * v_corridor.tile_size
		add_child(v_corridor)
		boss_chance += rng.randf_range(0.0, max_increment)
		v_corridor.propagate(is_boss_room_existent, boss_chance)
	return is_boss_room_existent


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
