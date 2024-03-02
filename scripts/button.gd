extends StaticBody3D

signal clicked()
signal unclicked()

@export var can_be_clicked := true
@export var in_duration := 0.2
@export var out_duration := 0.2
@export var push_amount := 0.5

@onready var default_position := position

var is_clicked := false

var tween: Tween

func click():
	if not can_be_clicked or is_clicked:
		return
	
	is_clicked = true
	emit_clicked()
	
	tween = create_tween()
	tween.tween_property(self, "position", default_position - Vector3(0.0, 0.0, %Shape.shape.size.z * push_amount), in_duration)

func unclick():
	if not can_be_clicked or not is_clicked:
		return
	
	var do_unclick = func():
		tween = create_tween()
		tween.tween_property(self, "position", default_position, out_duration)
		tween.finished.connect(func(): is_clicked = false)
		tween.finished.connect(emit_unclicked)
	if tween.is_running():
		tween.finished.connect(do_unclick)
	else:
		do_unclick.call()

func emit_clicked():
	clicked.emit()

func emit_unclicked():
	unclicked.emit()
