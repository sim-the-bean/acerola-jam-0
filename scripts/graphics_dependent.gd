extends Node3D

@export var minimum_graphics := GameSettings.Graphics.BALANCED

func _ready():
	set_graphics(GameSettings.graphics)
	GameSettings.setting_changed.connect(_on_setting_changed)

func _on_setting_changed(key: StringName, value: Variant):
	if key == &"graphics":
		set_graphics(value)

func set_graphics(graphics: GameSettings.Graphics):
	visible = GameSettings.graphics >= minimum_graphics
