@tool
extends Node
class_name UiHintComponent

enum HintType {
	LABEL,
	INTERACT,
	GRAB,
	THROW,
	JUMP,
	ZOOM,
	ROTATE_LEFT,
	ROTATE_RIGHT,
}

enum HudType {
	HUD_2D,
	CONTEXT_2D,
	CURSOR_3D,
}

@export var hint_type := HintType.LABEL:
	set(value):
		hint_type = value
		if hint_type == HintType.LABEL:
			default_hint = ""
		else:
			default_hint = HintType.find_key(hint_type).capitalize()
		notify_property_list_changed()
@export var hud_type := HudType.HUD_2D:
	set(value):
		hud_type = value
		match hud_type:
			HudType.CONTEXT_2D:
				if not show_was_set:
					_show = false
			_:
				_show = true
@export var hint: String
@export var show: bool = true:
	get: return _show
	set(value):
		_show = value
		show_was_set = true

var _show := true:
	set(value):
		_show = value
		show_in_hud()
var show_was_set := false
var default_hint := ""
var node: Control = null

func _ready():
	show_in_hud()

func show_in_hud():
	if not Engine.is_editor_hint():
		if _show:
			var h := hint if hint != null else default_hint
			node = GameManager.instance.player.hud_show_hint(hint_type, hud_type, h)
		else:
			GameManager.instance.player.hud_hide_hint(hud_type, node)
			node = null

func set_show():
	_show = true

func set_hide():
	_show = false

func _validate_property(property: Dictionary):
	if property.name == "hint":
		property.hint = PROPERTY_HINT_PLACEHOLDER_TEXT
		property.hint_string = default_hint
