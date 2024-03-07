extends Control

var main_scene := preload("res://scenes/main.tscn")

func _on_splash_screen_finished():
	get_tree().change_scene_to_packed(main_scene)
