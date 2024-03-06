@tool
extends Node3D

signal destroyed()

@export_category("Destructible")
@export var is_destroyed := false:
	get: return _is_destroyed
	set(value):
		if Engine.is_editor_hint():
			if value:
				force_destroy()
			else:
				force_undestroy()
		_is_destroyed = value
@export var minimum_momentum := 0.0

var _is_destroyed := false
@onready var red_buttons := $ControlPanel2/ControlPanel/Buttons
@onready var green_buttons := $ControlPanel2/ControlPanel/Buttons_001

func _on_hurtbox_body_entered(body):
	if body is Glitched:
		if body.can_destroy:
			destroy(body)
	else:
		destroy(body)

func destroy(node: Node3D = null):
	if _is_destroyed:
		return
	
	if node != null and node is RigidBody3D:
		if node.linear_velocity.length() * node.mass < minimum_momentum:
			return
	
	if node != null and node.has_method("destroy"):
		node.destroy()
	
	force_destroy()

func force_destroy():
	_is_destroyed = true
	var red_tween = create_tween()
	red_tween.set_loops(10)
	red_tween.tween_property(red_buttons.get_surface_override_material(0), "emission_energy_multiplier", 1.0, 0.07)
	red_tween.tween_property(red_buttons.get_surface_override_material(0), "emission_energy_multiplier", 0.0, 0.02)
	var green_tween = create_tween()
	green_tween.set_loops(12)
	green_tween.tween_property(green_buttons.get_surface_override_material(0), "emission_energy_multiplier", 1.0, 0.07)
	green_tween.tween_property(green_buttons.get_surface_override_material(0), "emission_energy_multiplier", 0.0, 0.02)
	emit_destroyed()

func force_undestroy():
	_is_destroyed = false
	red_buttons.get_surface_override_material(0).emission_energy_multiplier = 1.0
	green_buttons.get_surface_override_material(0).emission_energy_multiplier = 1.0

func emit_destroyed():
	destroyed.emit()
