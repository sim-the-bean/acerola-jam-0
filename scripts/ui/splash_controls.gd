extends Control

@export var jump_button: TextureRect
@export var xbox_button_jump: Texture2D
@export var ps_button_jump: Texture2D

func _ready():
	var joys := Input.get_connected_joypads()
	if not joys.is_empty():
		var input_type := ControllerType.get_type_by_name(joys.front())
		match input_type:
			ControllerType.InputType.XBOX:
				jump_button.texture = xbox_button_jump
			ControllerType.InputType.PLAYSTATION:
				jump_button.texture = ps_button_jump
