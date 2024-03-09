@tool
extends Label

@export var prefix := "Ver.":
	set(value):
		prefix = value
		reset_label()

func _ready():
	reset_label()

func reset_label():
	text = prefix.strip_edges() + " " + ProjectSettings.get_setting("application/config/version")
