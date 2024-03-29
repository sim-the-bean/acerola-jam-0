@tool
extends StaticBody3D

signal clicked()
signal unclicked()
signal clicked_locked()

@export_category("Button")
@export var can_be_clicked := true
@export var oneshot := false
@export var switch := false

@export_group("Animation")
@export var in_duration := 0.2
@export var out_duration := 0.2
@export var push_amount := 0.5

@export_group("Blinking")
@export_color_no_alpha var color := Color.RED:
	set(value):
		color = value
		%Mesh.mesh.material.albedo_color = color
		%Mesh.mesh.material.emission = color
@export_range(0.0, 2.0, 0.01, "or_greater") var emission_high := 1.0:
	set(value):
		emission_high = value
		%Mesh.mesh.material.emission_energy_multiplier = emission_high
		if emission_high > 0.0:
			%Mesh.mesh.material.emission_enabled = true
		else:
			%Mesh.mesh.material.emission_enabled = false
		set_blink()
@export_range(0.0, 2.0, 0.01, "or_greater") var emission_low := 0.0:
	set(value):
		emission_low = value
		set_blink()
@export var blink := true:
	set(value):
		blink = value
		set_blink()
@export var blink_speed := 1.0:
	set(value):
		blink_speed = value
		set_blink()

@onready var default_position := position

var is_clicked := false
var was_clicked := false

var tween: Tween
var blink_tween: Tween

func _ready():
	set_blink()

func set_blink():
	if not is_inside_tree():
		return
	if blink_tween != null:
		blink_tween.kill()
	if not blink or emission_high == 0.0:
		%Mesh.mesh.material.emission_energy_multiplier = emission_high
		return
	blink_tween = create_tween()
	blink_tween.set_loops()
	blink_tween.tween_property(%Mesh.mesh.material, "emission_energy_multiplier", emission_high, 0.0)
	blink_tween.tween_interval(blink_speed)
	blink_tween.tween_property(%Mesh.mesh.material, "emission_energy_multiplier", emission_low, 0.0)
	blink_tween.tween_interval(blink_speed)

func click():
	if switch:
		if is_clicked:
			switch_off()
		else:
			switch_on()
	else:
		switch_on()

func unclick():
	if not switch:
		switch_off()

func switch_on():
	if is_clicked:
		return
	if not can_be_clicked or (oneshot and was_clicked):
		clicked_locked.emit()
		%SoundBroken.play()
		return
	
	is_clicked = true
	was_clicked = true
	emit_clicked()
	
	tween = create_tween()
	tween.tween_property(self, "position", default_position - quaternion * Vector3(0.0, 0.0, %Shape.shape.size.z * push_amount), in_duration)
	
	%SoundOk.play()

func switch_off():
	if not can_be_clicked or not is_clicked:
		return
	
	var do_unclick = func():
		tween = create_tween()
		tween.tween_property(self, "position", default_position, out_duration)
		tween.finished.connect(func(): is_clicked = false)
		tween.finished.connect(emit_unclicked)
	if tween.is_running():
		tween.finished.connect(do_unclick)
	else:
		do_unclick.call()

func emit_clicked():
	clicked.emit()

func emit_unclicked():
	unclicked.emit()
