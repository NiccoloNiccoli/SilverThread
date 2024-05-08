extends Camera2D


@onready var noise = FastNoiseLite.new()

@export var decay : float = 0.5
@export var amplitude : float = 15.0

var trauma = 0.0
var trauma_power = 2
var NOISE_SPEED = 2
var _noise_y = 0

var elapsed_time = 0.0
func _ready():
	randomize()
	noise.set_seed(randi())
	noise.noise_type = FastNoiseLite.TYPE_PERLIN
	add_trauma(1)

func add_trauma(amount: float):
	trauma = min(trauma+amount, 1.0)

func _shake():
	var amount = pow(trauma, trauma_power)
	offset.x = amplitude * amount * noise.get_noise_2d(noise.seed, _noise_y)
	offset.y = amplitude * amount * noise.get_noise_2d(noise.seed * 2, _noise_y)

func _process(delta):
	elapsed_time += delta
	if elapsed_time > 10:
		add_trauma(1)
		elapsed_time = 0
	if trauma : 
		trauma = max(trauma - decay * delta, 0)
		_noise_y += NOISE_SPEED
		_shake()
	
