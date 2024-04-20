extends Node2D


const SPEED = 30
var is_visible = false
var direction = Vector2(0,0)
var tip = Vector2(0,0)

var initial_position = Vector2(0,0)
const MAX_DISTANCE = 500
const MIN_DISTANCE = 1

func shoot(pos:Vector2)->void:
	is_visible = true
	tip = pos
	
	
	
func release():
	is_visible = false
	
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	self.visible = is_visible
	if self.visible:
		$Needle.position = tip
		var local_tip = to_local(tip)
		$Needle.rotation = self.position.angle_to_point(tip) + deg_to_rad(90)
		$Thread.region_rect.size.y = tip.length() - 6 # 6 = magic number
		$Thread.rotation = self.position.angle_to_point(tip) - deg_to_rad(90)
	else:
		return
