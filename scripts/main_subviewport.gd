extends SubViewportContainer

#func _unhandled_input(event):
	#prints("unhandled", self, event)

func _input(event):
	$MainViewport.push_input(event)
