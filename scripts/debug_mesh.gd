extends Node3D

func _ready():
	visible = visible and OS.is_debug_build()
