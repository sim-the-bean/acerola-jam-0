@tool
extends StaticBody3D

signal opening()
signal opened()
signal closing()
signal closed()

@export_category("Door")
@export var is_open: bool = false:
	get: return _is_open
	set(value):
		if Engine.is_editor_hint():
			force_toggle()
		_is_open = value
@export var can_be_opened := true
@export var can_be_closed := true
@export var trigger_count := 1

@export_group("Animation")
@export var duration := 0.5
@export_range(0.0, 1.0, 0.1, "or_greater") var open_amount_right := 1.0
@export_range(0.0, 1.0, 0.1, "or_greater") var open_amount_left := 1.0

var default_position_right: Vector3
var default_position_left: Vector3

var _is_open := false
var is_opening := false
var is_closing := false
var is_moving: bool:
	get: return is_opening or is_closing
var trigger_counter := 0

var tween: Tween

func _ready():
	if tween != null:
		tween.kill()
	is_opening = false
	is_closing = false
	trigger_counter = 0
	tween = null
	
	reset_default_positions()
	if Engine.is_editor_hint():
		var create_timer: Callable
		create_timer = func():
			if not is_moving:
				reset_default_positions()
			var timer = get_tree().create_timer(1.0, true, false, true)
			timer.timeout.connect(create_timer)
	
	if not %RightHalf.shape.changed.is_connected(reset_default_positions):
		%RightHalf.shape.changed.connect(reset_default_positions)
	if not %LeftHalf.shape.changed.is_connected(reset_default_positions):
		%LeftHalf.shape.changed.connect(reset_default_positions)

func reset_default_positions():
	if _is_open:
		default_position_right = %RightHalf.position - Vector3(%RightHalf.shape.size.x * open_amount_right, 0.0, 0.0)
		default_position_left = %LeftHalf.position + Vector3(%LeftHalf.shape.size.x * open_amount_left, 0.0, 0.0)
	else:
		default_position_right = %RightHalf.position
		default_position_left = %LeftHalf.position

func toggle():
	if _is_open:
		close()
	else:
		open()

func force_toggle():
	if _is_open:
		force_close()
	else:
		force_open()

func open():
	if not can_be_opened:
		return
	
	if not (_is_open or is_opening):
		trigger_counter += 1
		if trigger_counter < trigger_count:
			return
	
	force_open()

func force_open():
	if _is_open or is_opening:
		return
		
	if is_closing:
		is_closing = false
		tween.kill()
	
	is_opening = true
	emit_opening()
	
	tween = create_tween()
	tween.tween_property(%RightHalf, "position", default_position_right + Vector3(%RightHalf.shape.size.x * open_amount_right, 0.0, 0.0), duration)
	tween.parallel().tween_property(%LeftHalf, "position", default_position_left - Vector3(%LeftHalf.shape.size.x * open_amount_left, 0.0, 0.0), duration)
	tween.finished.connect(func():
		is_opening = false
		_is_open = true)
	tween.finished.connect(emit_opened)

func close():
	if not can_be_closed:
		return
	
	force_close()

func force_close():
	if not _is_open or is_closing:
		return
	
	if is_opening:
		is_opening = false
		tween.kill()
	
	is_closing = true
	emit_closing()
	
	tween = create_tween()
	tween.tween_property(%RightHalf, "position", default_position_right, duration)
	tween.parallel().tween_property(%LeftHalf, "position", default_position_left, duration)
	tween.finished.connect(func():
		is_closing = false
		_is_open = false
		trigger_counter = 0)
	tween.finished.connect(emit_closed)

func emit_opening():
	opening.emit()

func emit_opened():
	opened.emit()

func emit_closing():
	closing.emit()

func emit_closed():
	closed.emit()
