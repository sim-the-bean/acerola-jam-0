extends Control

func _ready():
	if not OS.is_debug_build():
		%TestScene.visible = false

func _unhandled_input(event):
	for child in find_children("*"):
		if child.has_focus():
			return
	%NewGame.grab_focus()

func _on_new_game_pressed():
	GameManager.instance.new_game()

func _on_test_scene_pressed():
	GameManager.instance.play_test()

func _on_continue_pressed():
	GameManager.instance.continue_game()

func _on_settings_pressed():
	GameManager.instance.menu.page_index = 1

func _on_credits_pressed():
	GameManager.instance.menu.page_index = 2

func _on_quit_pressed():
	GameManager.instance.quit()
