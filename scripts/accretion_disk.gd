@tool
extends MeshInstance3D

@export_range(0.0, 90.0, 1.0, "radians_as_degrees") var angle := deg_to_rad(5)

func _process(delta):
	var target: Camera3D
	if Engine.is_editor_hint():
		target = EditorInterface.get_editor_viewport_3d().get_camera_3d()
	else:
		target = get_viewport().get_camera_3d()
	if is_inside_tree():
		rotation = Vector3(target.rotation.x + angle, target.rotation.y, 0.0)
