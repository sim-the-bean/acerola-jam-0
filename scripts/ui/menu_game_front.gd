extends Control

func _unhandled_input(event):
	for child in find_children("*"):
		if child.has_focus():
			return
	%Unpause.grab_focus()

func _on_unpause_pressed():
	GameManager.instance.unpause()

func _on_save_game_pressed():
	GameManager.instance.save_game()

func _on_restart_pressed():
	GameManager.instance.reset_to_checkpoint()

func _on_settings_pressed():
	GameManager.instance.menu.page_index = 1

func _on_quit_menu_pressed():
	GameManager.instance.switch_to_main_menu()

func _on_quit_pressed():
	GameManager.instance.quit()
