@tool
extends BaseEffect
class_name EffectCustomGravity

@export var gravity_direction := Vector3.DOWN:
	set(value):
		gravity_direction = value
		emit_changed()
@export var gravity_strength := 9.8:
	set(value):
		gravity_strength = value
		emit_changed()
var gravity: Vector3:
	get: return gravity_direction.normalized() * gravity_strength

func _on_enter(node: Node3D):
	if Engine.is_editor_hint():
		return
	var component: EffectComponent = node.get_node_or_null(^"EffectComponent")
	if component != null:
		if node is Player:
			component.replace_variable("gravity_direction", gravity_direction)
			component.replace_variable("gravity_strength", gravity_strength)
			node.gravity_field_counter += 1

func _on_leave(node: Node3D):
	if Engine.is_editor_hint():
		return
	var component: EffectComponent = node.get_node_or_null(^"EffectComponent")
	if component != null:
		if node is Player:
			node.gravity_field_counter -= 1
			if node.gravity_field_counter == 0:
				component.reset_variable("gravity_direction")
				component.reset_variable("gravity_strength")

func _on_changed(node: BaseZone):
	var area: Area3D = node.get_node("Area")
	area.gravity_space_override = Area3D.SPACE_OVERRIDE_REPLACE
	area.gravity_direction = gravity_direction
	area.gravity = gravity_strength
