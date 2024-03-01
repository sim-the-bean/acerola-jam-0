extends BaseEffect
class_name EffectInvertControls

func _on_enter(node: Node3D):
	var component: EffectComponent = node.get_node_or_null(^"EffectComponent")
	if component != null and node is Player:
		node.input_allowed = false
		component.replace_function("get_input_vector", func(this): return -this.get_input_vector())

func _on_leave(node: Node3D):
	var component: EffectComponent = node.get_node_or_null(^"EffectComponent")
	if component != null and node is Player:
		node.input_allowed = false
		component.reset_function("get_input_vector")

func _on_changed(_node: BaseZone):
	pass
