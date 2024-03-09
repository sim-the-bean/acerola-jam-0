@tool
extends RichTextLabel
class_name Header

@export_category("Header")
@export var title := "":
	set(value):
		title = value.to_upper()
		text = "[fill]" + title + "[/fill]"
