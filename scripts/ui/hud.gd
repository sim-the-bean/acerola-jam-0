extends Control

@export var button_prompt_interact: PackedScene = preload("res://scenes/ui/input_prompts/button_prompt_interact.tscn")
@export var button_prompt_grab: PackedScene = preload("res://scenes/ui/input_prompts/button_prompt_grab.tscn")
@export var button_prompt_throw: PackedScene = preload("res://scenes/ui/input_prompts/button_prompt_throw.tscn")
@export var button_prompt_jump: PackedScene = preload("res://scenes/ui/input_prompts/button_prompt_jump.tscn")
@export var button_prompt_zoom_in: PackedScene
@export var button_prompt_zoom_out: PackedScene
@export var button_prompt_rotate_left: PackedScene
@export var button_prompt_rotate_right: PackedScene

func show_hint(hint_type: UiHintComponent.HintType, hud_type: UiHintComponent.HudType, hint: String):
	var label := Label.new()
	label.text = hint
	var button_prompt: Control
	match hint_type:
		UiHintComponent.HintType.LABEL: button_prompt = Control.new()
		UiHintComponent.HintType.INTERACT: button_prompt = button_prompt_interact.instantiate()
		UiHintComponent.HintType.GRAB: button_prompt = button_prompt_grab.instantiate()
		UiHintComponent.HintType.THROW: button_prompt = button_prompt_throw.instantiate()
		UiHintComponent.HintType.JUMP: button_prompt = button_prompt_jump.instantiate()
		UiHintComponent.HintType.ZOOM_IN: button_prompt = button_prompt_zoom_in.instantiate()
		UiHintComponent.HintType.ZOOM_OUT: button_prompt = button_prompt_zoom_out.instantiate()
		UiHintComponent.HintType.ROTATE_LEFT: button_prompt = button_prompt_rotate_left.instantiate()
		UiHintComponent.HintType.ROTATE_RIGHT: button_prompt = button_prompt_rotate_right.instantiate()
	match hud_type:
		UiHintComponent.HudType.CONTEXT_2D:
			%ContextHints.add_child(button_prompt)
			%ContextHints.add_child(label)
		UiHintComponent.HudType.HUD_2D:
			%StaticHints.add_child(label)
			%StaticHints.add_child(button_prompt)
	return button_prompt

func hide_hint(hud_type: UiHintComponent.HudType, node: Control):
	var parent := %ContextHints if hud_type == UiHintComponent.HudType.CONTEXT_2D else %StaticHints
	var idx := parent.get_children().find(node)
	if idx != -1:
		var label_idx := idx + 1 if hud_type == UiHintComponent.HudType.CONTEXT_2D else idx - 1
		var label := parent.get_child(label_idx)
		
		parent.remove_child(node)
		parent.remove_child(label)
