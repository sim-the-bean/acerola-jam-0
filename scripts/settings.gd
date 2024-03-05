extends Node

const config_path := "user://config.cfg"

var mouse_look_sensitivity := 0.3:
	set(value):
		mouse_look_sensitivity = value
		config.set_value("Settings", "mouse_look_sensitivity", value)
		save_settings()
var controller_look_sensitivity := 0.6:
	set(value):
		controller_look_sensitivity = value
		config.set_value("Settings", "controller_look_sensitivity", value)
		save_settings()
var look_invert_x := false:
	set(value):
		look_invert_x = value
		config.set_value("Settings", "look_invert_x", value)
		save_settings()
var look_invert_y := false:
	set(value):
		look_invert_y = value
		config.set_value("Settings", "look_invert_y", value)
		save_settings()
var look_invert: Vector2:
	get: return Vector2(-1.0 if look_invert_x else 1.0, -1.0 if look_invert_y else 1.0)

var config := ConfigFile.new()
var save_to_file := false

func _init():
	load_settings()
	if not Engine.is_editor_hint():
		save_to_file = true

func save_settings():
	if save_to_file:
		config.save(config_path)

func load_settings():
	var err := config.load(config_path)
	
	if err != OK:
		return
	
	for key in config.get_section_keys("Settings"):
		set(key, config.get_value("Settings", key))
