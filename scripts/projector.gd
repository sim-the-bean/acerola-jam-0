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
		if is_powered:
			if wheel_tween != null: wheel_tween.play()
			emit_powered_on()
		else:
			if wheel_tween != null: wheel_tween.pause()
			emit_powered_off()
@export var permanent_unglitch := false
@export_group("Visuals")
@export var wheel_spin_duration := 2.0:
	set(value):
		wheel_spin_duration = value
		if is_inside_tree():
			restart()

var wheel_tween: Tween = null
@onready var wheel1 = $Mesh/Wheel1
@onready var wheel2 = $Mesh/Wheel2

func _ready():
	restart()

func restart():
	if wheel_tween != null:
		wheel_tween.kill()
	wheel_tween = create_tween()
	wheel_tween.set_loops()
	wheel_tween.tween_property(wheel1, "rotation:x", TAU, wheel_spin_duration)
	wheel_tween.parallel().tween_property(wheel2, "rotation:x", TAU, wheel_spin_duration)
	wheel_tween.tween_property(wheel1, "rotation:x", 0.0, 0.0)
	wheel_tween.tween_property(wheel2, "rotation:x", 0.0, 0.0)
	if is_powered:
		wheel_tween.play()
	else:
		wheel_tween.pause()

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
