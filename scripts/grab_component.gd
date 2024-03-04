extends Node

signal grab_begin()
signal grab_end()

func emit_grab_begin():
	grab_begin.emit()

func emit_grab_end():
	grab_end.emit()
