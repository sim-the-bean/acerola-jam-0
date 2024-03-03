extends Control

func _on_new_game_pressed():
	GameManager.instance.new_game()

func _on_continue_pressed():
	GameManager.instance.continue_game()

func _on_settings_pressed():
	pass # Replace with function body.

func _on_quit_pressed():
	GameManager.instance.quit()
