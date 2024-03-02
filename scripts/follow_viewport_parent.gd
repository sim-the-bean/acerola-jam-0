@tool
extends MeshInstance3D

@export_node_path("Node3D") var node_path: NodePath = ^"../.."

func _process(delta):
	if is_inside_tree():
		var node = get_node(node_path)
		global_transform = node.global_transform
