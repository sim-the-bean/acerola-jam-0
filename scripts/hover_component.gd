extends Node

signal hover_entered()
signal hover_exited()

var is_hovered := false

func emit_hover_entered():
	is_hovered = true
	hover_entered.emit()

func emit_hover_exited():
	is_hovered = false
	hover_exited.emit()
