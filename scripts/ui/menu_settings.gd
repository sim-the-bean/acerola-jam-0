extends Control

func _ready():
	%MouseSensitivitySlider.value = GameSettings.mouse_look_sensitivity * 10
	%ControllerSensitivitySlider.value = GameSettings.controller_look_sensitivity
	%InvertCameraXCheck.button_pressed = GameSettings.look_invert_x
	%InvertCameraYCheck.button_pressed = GameSettings.look_invert_y

func _on_mouse_sensitivity_slider_value_changed(value):
	GameSettings.mouse_look_sensitivity = value * 0.1

func _on_controller_sensitivity_slider_value_changed(value):
	GameSettings.controller_look_sensitivity = value * 0.1

func _on_invert_camera_x_check_toggled(toggled_on):
	GameSettings.look_invert_x = toggled_on

func _on_invert_camera_y_check_toggled(toggled_on):
	GameSettings.look_invert_y = toggled_on
