extends Node

var mouse_focus: bool:
	get: return Input.mouse_mode == Input.MOUSE_MODE_CAPTURED
	set(value):
		if value:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		else:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
