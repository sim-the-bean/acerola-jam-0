@tool
extends Light3D

@export_category("Flickering")
@export var flicker_enabled := true:
	set(value):
		flicker_enabled = value
		if tween != null:
			if flicker_enabled:
				tween.play()
			else:
				tween.pause()
@export var flicker := 0.2:
	set(value):
		flicker = value
		flicker_min = 1.0 - flicker
		flicker_max = 1.0 + flicker
		restart()
@export var duration := 0.01:
	set(value):
		duration = value
		restart()

@onready var default_energy := light_energy
var flicker_min := 0.8
var flicker_max := 1.2

var tween: Tween = null

func _ready():
	restart()

func restart():
	if tween != null:
		tween.kill()
	tween = create_tween()
	tween.set_loops()
	tween.set_trans(Tween.TRANS_SINE)
	tween.tween_property(self, "light_energy", flicker_min, duration)
	tween.tween_property(self, "light_energy", flicker_max, duration)
