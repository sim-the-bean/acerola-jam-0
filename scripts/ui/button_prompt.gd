@tool
extends TextureRect
class_name ButtonPrompt

enum Mode {
	MOUSE_AND_KEYBOARD,
	CONTROLLER,
	XBOX,
	PS,
}

static var global_last_mode := Mode.MOUSE_AND_KEYBOARD

@export_category("Button Prompt")
@export var default_mode := Mode.MOUSE_AND_KEYBOARD:
	set(value):
		default_mode = value
		if Engine.is_editor_hint():
			mode = default_mode
@export_group("Icons")
@export var mouse_and_keyboard_icon: Texture2D:
	set(value):
		mouse_and_keyboard_icon = value
		update_mode()
@export var controller_icon: Texture2D:
	set(value):
		controller_icon = value
		update_mode()
@export var xbox_icon: Texture2D:
	set(value):
		xbox_icon = value
		update_mode()
@export var ps_icon: Texture2D:
	set(value):
		ps_icon = value
		update_mode()

var mode := Mode.MOUSE_AND_KEYBOARD:
	set(value):
		if mode != value:
			mode = value
			update_mode()

func _ready():
	mode = global_last_mode
	update_mode()

func update_mode():
	match mode:
		Mode.MOUSE_AND_KEYBOARD: texture = mouse_and_keyboard_icon
		Mode.CONTROLLER: texture = controller_icon
		Mode.XBOX: texture = xbox_icon
		Mode.PS: texture = ps_icon

func _unhandled_input(event: InputEvent):
	if Engine.is_editor_hint():
		return
	if event is InputEventJoypadButton or event is InputEventJoypadMotion:
		var type := GameControllerDb.get_type_by_name(event.device)
		match type:
			GameControllerDb.GameControllerType.XBOX:
				if xbox_icon != null:
					mode = Mode.XBOX
				elif controller_icon != null:
					mode = Mode.CONTROLLER
				else:
					mode = Mode.MOUSE_AND_KEYBOARD
			GameControllerDb.GameControllerType.PLAYSTATION:
				if ps_icon != null:
					mode = Mode.PS
				elif controller_icon != null:
					mode = Mode.CONTROLLER
				else:
					mode = Mode.MOUSE_AND_KEYBOARD
			_:
				if controller_icon != null:
					mode = Mode.CONTROLLER
				elif xbox_icon != null:
					mode = Mode.XBOX
				elif ps_icon != null:
					mode = Mode.PS
				else:
					mode = Mode.MOUSE_AND_KEYBOARD
	elif event is InputEventMouse or event is InputEventKey:
		mode = Mode.MOUSE_AND_KEYBOARD
	global_last_mode = mode
