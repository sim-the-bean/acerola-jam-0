@tool
extends Camera3D

func _process(delta):
	var target: Camera3D
	if Engine.is_editor_hint():
		target = EditorInterface.get_editor_viewport_3d().get_camera_3d()
	else:
		target = get_viewport().get_parent().get_viewport().get_camera_3d()
	if is_inside_tree():
		global_transform = target.global_transform
	h_offset = target.h_offset
	v_offset = target.v_offset
	fov = target.fov
	near = target.near
	far = target.far
