extends Node2D

@onready var thread = $Thread
@onready var needle = $Needle
var direction := Vector2(0,0)
var tip := Vector2(0,0)

const SPEED = 60
var flying = false
var hooked = false

func shoot(dir: Vector2) -> void:
	direction = dir.normalized()
	print("Direction ", direction)
	flying = true
	tip = self.global_position
	
func release() -> void:
	flying = false
	hooked = false

func _process(_delta:float) -> void:
	self.visible = flying or hooked
	if not self.visible:
		return
	var tip_loc = to_local(tip)
	thread.rotation = self.position.angle_to_point(tip_loc) 
	needle.rotation = self.position.angle_to_point(tip_loc)
	thread.position = tip_loc
	print(tip_loc.length())
	thread.region_rect.size.y = tip_loc.length()
	print(thread.region_rect.size)


	

func _physics_process(_delta:float) -> void:
	needle.global_position = tip
	if flying:
		print("Dir ", direction)
		if needle.move_and_collide(direction * SPEED):
			hooked = true
			flying = false
	tip = needle.global_position
