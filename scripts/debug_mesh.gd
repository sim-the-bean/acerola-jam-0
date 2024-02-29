extends Node3D

func _ready():
	visible = OS.is_debug_build()
