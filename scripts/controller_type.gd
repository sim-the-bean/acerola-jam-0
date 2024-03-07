extends Node

signal input_type_changed(input_type: InputType)

enum InputType {
	OTHER,
	XBOX,
	PLAYSTATION,
	SWITCH,
	STEAM,
	MOUSE_AND_KEYBOARD,
}

var overrides: Dictionary = {}
var input_type := InputType.MOUSE_AND_KEYBOARD

func _unhandled_input(event):
	if Engine.is_editor_hint():
		return
	var old_type := input_type
	if event is InputEventJoypadButton or event is InputEventJoypadMotion:
		input_type = get_type_by_name(event.device)
	elif event is InputEventKey or event is InputEventMouse:
		input_type = InputType.MOUSE_AND_KEYBOARD
	if input_type != old_type:
		input_type_changed.emit(input_type)

func get_type_by_name(device_id := 0) -> InputType:
	if overrides.has(device_id):
		return overrides[device_id]
	var joy_name = Input.get_joy_name(device_id).to_lower()
	if joy_name.contains("xbox") or joy_name.contains("series") or joy_name.contains("microsoft"):
		return InputType.XBOX
	elif joy_name.contains("ps") or joy_name.contains("playstation") or joy_name.contains("play station") or joy_name.contains("shock") or joy_name.contains("sony"):
		return InputType.PLAYSTATION
	elif joy_name.contains("switch") or joy_name.contains("nintendo"):
		return InputType.SWITCH
	elif joy_name.contains("steam") or joy_name.contains("valve"):
		return InputType.STEAM
	elif joy_name.contains("xinput"):
		return GameSettings.xinput_type
	return InputType.OTHER
