@tool
extends RichTextLabel

@export_multiline var text_ongoing := "":
	set(value):
		text_ongoing = value
		reset_text()
@export_multiline var text_ended := "":
	set(value):
		text_ended = value
		reset_text()
@export var end_time := 1710399540

func _ready():
	reset_text()

func reset_text():
	if Time.get_unix_time_from_system() >= end_time:
		text = text_ended
	else:
		text = text_ongoing
	
