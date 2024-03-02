@tool
extends DirectionalLight3D

func _process(delta):
	var target: Camera3D
	if Engine.is_editor_hint():
		target = EditorInterface.get_editor_viewport_3d().get_camera_3d()
	else:
		target = get_viewport().get_camera_3d()
	if is_inside_tree():
		var camera_rotation := target.global_basis.get_rotation_quaternion()
		global_rotation = (camera_rotation * Quaternion(Vector3.UP, PI)).get_euler()
