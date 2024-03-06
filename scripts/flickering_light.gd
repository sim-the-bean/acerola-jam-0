@tool
extends Light3D

@export_category("Flickering")
@export var flicker_enabled := true:
	set(value):
		flicker_enabled = value
		restart()
@export var flicker := 0.2:
	set(value):
		flicker = value
		restart()
@export var frequency := 0.5:
	set(value):
		frequency = value
		restart()
@export var octaves := 1
@export var lacunarity := 2.0
@export var gain := 0.5
@export var base_light_energy := 1.0

var flicker_min: float:
	get: return base_light_energy - flicker
var flicker_max: float:
	get: return base_light_energy + flicker

var tween: Tween = null

func _ready():
	restart()

func restart():
	if not is_inside_tree():
		return
	if tween != null:
		tween.kill()
		tween = null
	if flicker_enabled:
		tween = create_tween()
		tween.set_loops()
		tween.set_trans(Tween.TRANS_LINEAR)
		tween.tween_method(set_flicker, 0.0, PI, frequency)

func set_flicker(x: float):
	var y = 0.0
	var freq = 1.0
	var amplitude = 1.0
	var sum := 0.0
	for i in octaves:
		sum += amplitude
		y += sin(x * freq) * amplitude
		freq *= lacunarity
		amplitude *= gain
	y /= sum
	light_energy = flicker_min + y * (flicker_max - flicker_min)
