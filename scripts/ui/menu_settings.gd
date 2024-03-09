extends Control

func _ready():
	%MouseSensitivitySlider.value = GameSettings.mouse_look_sensitivity * 10
	%ControllerSensitivitySlider.value = GameSettings.controller_look_sensitivity * 10
	%InvertCameraXCheck.button_pressed = GameSettings.look_invert_x
	%InvertCameraYCheck.button_pressed = GameSettings.look_invert_y
	%ViewBobbingCheck.button_pressed = GameSettings.bobbing_enabled
	%GraphicsSlider.value = GameSettings.graphics

func _unhandled_input(event):
	initial_focus()

func initial_focus():
	for child in find_children("*"):
		if child.has_focus():
			return
	%MouseSensitivitySlider.grab_focus()

func release_focus_recursive():
	for child in find_children("*"):
		if child.has_focus():
			child.release_focus()

func _on_mouse_sensitivity_slider_value_changed(value):
	GameSettings.mouse_look_sensitivity = value * 0.1

func _on_controller_sensitivity_slider_value_changed(value):
	GameSettings.controller_look_sensitivity = value * 0.1

func _on_invert_camera_x_check_toggled(toggled_on):
	GameSettings.look_invert_x = toggled_on

func _on_invert_camera_y_check_toggled(toggled_on):
	GameSettings.look_invert_y = toggled_on

func _on_view_bobbing_check_toggled(toggled_on):
	GameSettings.bobbing_enabled = toggled_on

func _on_graphics_slider_value_changed(value):
	GameSettings.graphics = value
