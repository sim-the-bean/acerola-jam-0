@tool
extends SubViewport

func _process(delta):
	var target: Viewport
	if Engine.is_editor_hint():
		target = EditorInterface.get_editor_viewport_3d()
	else:
		target = get_tree().root.get_viewport()
	size = target.size
