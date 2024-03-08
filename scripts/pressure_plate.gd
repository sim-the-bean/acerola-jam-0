@tool
extends Node3D

signal powered_on()
signal powered_off()

@export var press_down := 0.05
@export var animation_duration := 0.5
@export var debug_toggle: bool:
	set(value):
		if OS.is_debug_build():
			if is_powered_on or is_moving_down:
				toggle_off()
			else:
				toggle_on()

var tween_down: Tween
var tween_up: Tween

var currently_pushing_down: Node3D
var is_moving_down := false
var is_moving_up := false
var is_moving: bool:
	get: return is_moving_down or is_moving_up
var is_powered_on := false

@onready var button_material: StandardMaterial3D = %ButtonMesh.mesh.material

func _on_hitbox_body_entered(body):
	if currently_pushing_down == null and body.has_node("PushDownComponent"):
		currently_pushing_down = body
		toggle_on()

func toggle_on():
	if is_moving_down:
		return
	var duration := animation_duration
	if is_moving_up:
		is_moving_up = false
		duration = tween_up.get_total_elapsed_time()
		tween_up.kill()
		tween_up = null
	
	is_moving_down = true
	
	tween_down = create_tween()
	tween_down.tween_property(%Button, "position:y", -press_down, duration)
	tween_down.tween_property(self, "is_powered_on", true, 0.0)
	tween_down.tween_property(button_material, "emission_enabled", true, 0.0)
	tween_down.tween_callback(%SoundOn.play)
	tween_down.tween_callback(emit_powered_on)
	tween_down.tween_property(self, "is_moving_down", false, 0.0)

func _on_hitbox_body_exited(body):
	if body == currently_pushing_down:
		currently_pushing_down = null
		toggle_off()

func toggle_off():
	if is_moving_up:
		return
	var duration := animation_duration
	if is_moving_down:
		is_moving_down = false
		duration = tween_down.get_total_elapsed_time()
		tween_down.kill()
		tween_down = null
	
	is_moving_up = true
	
	tween_up = create_tween()
	tween_up.tween_property(%Button, "position:y", 0, duration)
	tween_up.tween_property(self, "is_moving_up", false, 0.0)
	%SoundOff.play()
	is_powered_on = false
	button_material.emission_enabled = false
	emit_powered_off()

func emit_powered_on():
	powered_on.emit()

func emit_powered_off():
	powered_off.emit()

