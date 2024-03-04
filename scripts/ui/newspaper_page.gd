@tool
extends Node3D
class_name NewspaperPage

signal opening()
signal opened()
signal closing()
signal closed()

@export var page: PackedScene:
	set(value):
		page = value
		if is_inside_tree():
			if page_node != null:
				page_node.queue_free()
			page_node = page.instantiate()
			%SubViewport.add_child(page_node)
@export var animation_name := &"TurnPage"
@export var is_open := false:
	get: return _is_open
	set(value):
		if value:
			open()
		else:
			close()
@export var enabled := true

@onready var animation_player: AnimationPlayer = $Mesh/AnimationPlayer
@onready var area_shape_size: Vector3 = %Area.get_node("Collider").shape.size

var _is_open := false
var is_opening := false
var is_closing := false
var is_moving: bool:
	get: return is_opening or is_closing
var is_valid: bool:
	get: return animation_player != null and animation_name != null

var page_node: Control = null
var is_mouse_inside := false
var is_mouse_held := false
var has_last_mouse_pos := false
var last_mouse_pos := Vector2.ZERO

func _ready():
	if page != null:
		page_node = page.instantiate()
		%SubViewport.add_child(page_node)
		page_node.queue_redraw()

func open():
	if is_open or is_opening or not is_valid:
		return
	
	is_opening = true
	
	enabled = false
	
	emit_opening()
	animation_player.play(animation_name)
	animation_player.animation_finished.connect(emit_opened.unbind(1), CONNECT_ONE_SHOT)
	animation_player.animation_finished.connect(func(_name):
		_is_open = true
		is_opening = false,
		CONNECT_ONE_SHOT)

func close():
	if not is_open or is_closing or not is_valid:
		return
	
	is_closing = true
	
	emit_closing()
	animation_player.play_backwards(animation_name)
	animation_player.animation_finished.connect(emit_closed.unbind(1), CONNECT_ONE_SHOT)
	animation_player.animation_finished.connect(func(_name):
		_is_open = false
		is_closing = false,
		CONNECT_ONE_SHOT)

func _unhandled_input(event):
	if Engine.is_editor_hint():
		return
	
	if not enabled:
		return
	
	if event is InputEventJoypadButton and event.is_action_pressed(&"game_cancel"):
		get_parent().previous_page()
		return
	
	var is_mouse_event := event is InputEventMouseButton or event is InputEventMouseMotion
	
	if not is_mouse_event:
		%SubViewport.push_input(event)

func _on_area_input_event(camera: Camera3D, event: InputEvent, mouse_position: Vector3, normal: Vector3, shape_idx: int):
	if Engine.is_editor_hint():
		return
	
	if not enabled:
		if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
			get_parent().previous_page()
		return
	
	var is_mouse_event := event is InputEventMouseButton or event is InputEventMouseMotion
	
	if is_mouse_event and (is_mouse_inside or is_mouse_held):
		handle_mouse_event(camera, event, mouse_position, normal, shape_idx)
	else:
		%SubViewport.push_input(event)

func handle_mouse_event(camera: Camera3D, event: InputEvent, mouse_position: Vector3, normal: Vector3, shape_idx: int):
	# Detect mouse being held to mantain event while outside of bounds. Avoid orphan clicks
	if event is InputEventMouseButton or event is InputEventScreenTouch:
		is_mouse_held = event.pressed
	
	mouse_position = %Area.global_transform.inverse() * mouse_position
	var mouse_pos := Vector2(mouse_position.x, mouse_position.z) / Vector2(area_shape_size.x, area_shape_size.z)
	mouse_pos = mouse_pos + Vector2(0.5, 0.5)
	mouse_pos *= Vector2(%SubViewport.size)
	
	event.position = mouse_pos
	event.global_position = mouse_pos
	
	if event is InputEventMouseMotion:
		if not has_last_mouse_pos:
			event.relative = Vector2.ZERO
		else:
			event.relative = mouse_pos - last_mouse_pos
	last_mouse_pos = mouse_pos
	
	%SubViewport.push_input(event)

func _on_area_mouse_entered():
	if Engine.is_editor_hint():
		return
	is_mouse_inside = true

func _on_area_mouse_exited():
	if Engine.is_editor_hint():
		return
	is_mouse_inside = false

func emit_opening():
	opening.emit()

func emit_opened():
	opened.emit()

func emit_closing():
	closing.emit()

func emit_closed():
	closed.emit()
