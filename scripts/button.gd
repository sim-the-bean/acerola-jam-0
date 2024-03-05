extends StaticBody3D

signal clicked()
signal unclicked()

@export_category("Button")
@export var can_be_clicked := true
@export var oneshot := false
@export var switch := false

@export_group("Animation")
@export var in_duration := 0.2
@export var out_duration := 0.2
@export var push_amount := 0.5

@onready var default_position := position

var is_clicked := false
var was_clicked := false

var tween: Tween

func click():
	if switch:
		if is_clicked:
			switch_off()
		else:
			switch_on()
	else:
		switch_on()

func unclick():
	if not switch:
		switch_off()

func switch_on():
	if not can_be_clicked or is_clicked or (oneshot and was_clicked):
		return
	
	is_clicked = true
	was_clicked = true
	emit_clicked()
	
	tween = create_tween()
	tween.tween_property(self, "position", default_position - Vector3(0.0, 0.0, %Shape.shape.size.z * push_amount), in_duration)

func switch_off():
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
