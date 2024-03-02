extends Node3D

func _on_killbox_body_entered(body: Node3D):
	if not is_inside_tree():
		return
	var kill_component = body.get_node_or_null(^"KillComponent")
	if kill_component != null:
		kill_component.kill()

func _on_hitbox_body_entered(node: Node3D):
	if not is_inside_tree():
		return
	var component: EffectComponent = node.get_node_or_null(^"EffectComponent")
	if component != null and node is Player:
		component.replace_variable("gravity_point", true)
		component.replace_variable("gravity_point_unit_distance", %Hitbox.gravity_point_unit_distance)
		component.replace_variable("gravity_point_center", global_position + %Hitbox.gravity_point_center)
		component.replace_variable("gravity_point_strength", %Hitbox.gravity)

func _on_hitbox_body_exited(node: Node3D):
	if not is_inside_tree():
		return
	var component: EffectComponent = node.get_node_or_null(^"EffectComponent")
	if component != null and node is Player:
		component.reset_variable("gravity_point")
		component.reset_variable("gravity_point_unit_distance")
		component.reset_variable("gravity_point_center")
		component.reset_variable("gravity_point_strength")
