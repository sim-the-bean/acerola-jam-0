extends BaseEffect
class_name EffectGravityScale

@export_range(0.0, 2.0, 0.1, "or_greater") var scale := 1.0

func _on_enter(node: Node3D):
	var component: EffectComponent = node.get_node_or_null(^"EffectComponent")
	if component != null:
		component.replace_variable("gravity_scale", scale)

func _on_leave(node: Node3D):
	var component: EffectComponent = node.get_node_or_null(^"EffectComponent")
	if component != null:
		component.reset_variable("gravity_scale")

func _on_changed(_node: BaseZone):
	pass
