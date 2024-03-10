@tool
extends RigidBody3D

signal powered_on()
signal powered_off()
signal entered_light(node: Node3D)
signal left_light(node: Node3D)

@export_category("Projector")
@export var is_powered := true:
	set(value):
		is_powered = value
		if is_inside_tree():
			%Light.visible = is_powered
			%Hitbox.process_mode = Node.PROCESS_MODE_INHERIT if is_powered else Node.PROCESS_MODE_DISABLED
			toggle(true)
@export var permanent_unglitch := false
@export_group("Visuals")
@export var wheel_spin_duration := 2.0:
	set(value):
		wheel_spin_duration = value
		if is_inside_tree():
			restart()

var wheel_tween: Tween = null
var toggle_tween: Tween = null
@onready var wheel1 = find_child("Wheel1")
@onready var wheel2 = find_child("Wheel2")

func _ready():
	restart()
	powered_on.connect(%SoundOn.play)
	powered_off.connect(%SoundOff.play)

func restart():
	if wheel_tween != null:
		wheel_tween.kill()
	wheel_tween = create_tween()
	wheel_tween.set_loops()
	wheel_tween.tween_property(wheel1, "rotation:x", 0.0, 0.0)
	wheel_tween.tween_property(wheel2, "rotation:x", 0.0, 0.0)
	wheel_tween.tween_property(wheel1, "rotation:x", TAU, wheel_spin_duration)
	wheel_tween.parallel().tween_property(wheel2, "rotation:x", TAU, wheel_spin_duration)
	toggle(false)

func toggle(emit_signals: bool):
	if is_powered:
		wheel_tween.play()
		if toggle_tween != null:
			toggle_tween.kill()
		toggle_tween = create_tween()
		toggle_tween.set_trans(Tween.TRANS_SINE)
		toggle_tween.tween_method(wheel_tween.set_speed_scale, 0.0, 1.0, 0.4)
		if emit_signals: emit_powered_on()
	else:
		if toggle_tween != null:
			toggle_tween.kill()
		toggle_tween = create_tween()
		toggle_tween.set_trans(Tween.TRANS_SINE)
		toggle_tween.tween_method(wheel_tween.set_speed_scale, 1.0, 0.0, 1.0)
		toggle_tween.tween_callback(wheel_tween.pause)
		if emit_signals: emit_powered_off()

func click():
	is_powered = not is_powered

func unclick():
	pass

func _on_hitbox_body_entered(body: Node3D):
	if body.is_in_group("glitched"):
		body.set_unglitched()
	emit_entered_light(body)

func _on_hitbox_body_exited(body):
	if not permanent_unglitch and body.is_in_group("glitched"):
		body.set_glitched()
	emit_left_light(body)

func emit_powered_on():
	powered_on.emit()

func emit_powered_off():
	powered_off.emit()

func emit_entered_light(node: Node3D):
	entered_light.emit(node)

func emit_left_light(node: Node3D):
	left_light.emit(node)
