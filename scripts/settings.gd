extends Node

enum Graphics {
	FAST,
	BALANCED,
	PRETTY,
}

enum AntiAliasing {
	NONE,
	MSAA,
	FXAA,
	TAA,
}

signal setting_changed(key: StringName, value: Variant)

const config_path := "user://config.cfg"

var mouse_look_sensitivity := 0.5:
	set(value):
		mouse_look_sensitivity = value
		setting_changed.emit("mouse_look_sensitivity", mouse_look_sensitivity)
		config.set_value("Settings", "mouse_look_sensitivity", value)
		save_settings()
var controller_look_sensitivity := 0.5:
	set(value):
		controller_look_sensitivity = value
		setting_changed.emit("controller_look_sensitivity", controller_look_sensitivity)
		config.set_value("Settings", "controller_look_sensitivity", value)
		save_settings()
var look_invert_x := false:
	set(value):
		look_invert_x = value
		setting_changed.emit("look_invert_x", look_invert_x)
		config.set_value("Settings", "look_invert_x", value)
		save_settings()
var look_invert_y := false:
	set(value):
		look_invert_y = value
		setting_changed.emit("look_invert_y", look_invert_y)
		config.set_value("Settings", "look_invert_y", value)
		save_settings()
var look_invert: Vector2:
	get: return Vector2(-1.0 if look_invert_x else 1.0, -1.0 if look_invert_y else 1.0)
var bobbing_enabled := true:
	set(value):
		bobbing_enabled = value
		setting_changed.emit("bobbing_enabled", bobbing_enabled)
		config.set_value("Settings", "bobbing_enabled", value)
		save_settings()
var graphics := Graphics.PRETTY if OS.is_debug_build() else Graphics.FAST:
	set(value):
		graphics = value
		setting_changed.emit("graphics", graphics)
		config.set_value("Settings", "graphics", value)
		save_settings()
var anti_aliasing := AntiAliasing.FXAA:
	set(value):
		anti_aliasing = value
		set_aa()
		setting_changed.emit("anti_aliasing", anti_aliasing)
		config.set_value("Settings", "anti_aliasing", anti_aliasing)
		save_settings()
var xinput_type := ControllerType.InputType.OTHER

var config := ConfigFile.new()
var save_to_file := false

func _init():
	load_settings()
	if not Engine.is_editor_hint():
		save_to_file = true
	set_aa()

func set_aa():
	match anti_aliasing:
		AntiAliasing.NONE:
			ProjectSettings.set_setting("rendering/anti_aliasing/quality/msaa_3d", 0)
			ProjectSettings.set_setting("rendering/anti_aliasing/quality/screen_space_aa", 0)
			ProjectSettings.set_setting("rendering/anti_aliasing/quality/use_taa", false)
		AntiAliasing.FXAA:
			ProjectSettings.set_setting("rendering/anti_aliasing/quality/msaa_3d", 0)
			ProjectSettings.set_setting("rendering/anti_aliasing/quality/screen_space_aa", 1)
			ProjectSettings.set_setting("rendering/anti_aliasing/quality/use_taa", false)
		AntiAliasing.MSAA:
			ProjectSettings.set_setting("rendering/anti_aliasing/quality/msaa_3d", 2)
			ProjectSettings.set_setting("rendering/anti_aliasing/quality/screen_space_aa", 0)
			ProjectSettings.set_setting("rendering/anti_aliasing/quality/use_taa", false)
		AntiAliasing.TAA:
			ProjectSettings.set_setting("rendering/anti_aliasing/quality/msaa_3d", 0)
			ProjectSettings.set_setting("rendering/anti_aliasing/quality/screen_space_aa", 0)
			ProjectSettings.set_setting("rendering/anti_aliasing/quality/use_taa", true)

func save_settings():
	if save_to_file:
		config.save(config_path)

func load_settings():
	var err := config.load(config_path)
	
	if err != OK:
		return
	
	for key in config.get_section_keys("Settings"):
		set(key, config.get_value("Settings", key))
