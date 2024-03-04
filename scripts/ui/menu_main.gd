extends Control

func _unhandled_input(event):
	for child in find_children("*"):
		if child.has_focus():
			return
	%NewGame.grab_focus()

func _on_new_game_pressed():
	GameManager.instance.new_game()

func _on_continue_pressed():
	GameManager.instance.continue_game()

func _on_settings_pressed():
	GameManager.instance.menu.page_index = 1

func _on_quit_pressed():
	GameManager.instance.quit()
