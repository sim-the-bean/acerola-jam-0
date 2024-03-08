extends Node
class_name GrabComponent

signal grab_begin()
signal grab_end()

const FLAG_LOCK_NONE := 0
const FLAG_LOCK_X := 1
const FLAG_LOCK_Y := 2
const FLAG_LOCK_Z := 4
const FLAG_LOCK_ALL := 7

@export var enabled := true
@export var linear_damp := 10.0
@export var angular_damp := 10.0
@export var rotate_axis := Vector3.UP
@export_flags("X", "Y", "Z") var axis_lock := FLAG_LOCK_NONE
@export var rotate_speed_multiplier := 1.0

var is_grabbed := false
@onready var default_linear_damp: float = get_parent().linear_damp
@onready var default_angular_damp: float = get_parent().angular_damp
@onready var default_axis_lock_angular_x = get_parent().axis_lock_angular_x
@onready var default_axis_lock_angular_y = get_parent().axis_lock_angular_y
@onready var default_axis_lock_angular_z = get_parent().axis_lock_angular_z
@onready var parent_rotation: Quaternion = get_parent().quaternion

func grab() -> bool:
	if enabled:
		get_parent().linear_damp = linear_damp
		get_parent().angular_damp = angular_damp
		if (axis_lock & FLAG_LOCK_X) != 0: get_parent().axis_lock_angular_x = true
		if (axis_lock & FLAG_LOCK_Y) != 0: get_parent().axis_lock_angular_y = true
		if (axis_lock & FLAG_LOCK_Z) != 0: get_parent().axis_lock_angular_z = true
		is_grabbed = true
		parent_rotation = get_parent().quaternion
		emit_grab_begin()
	return enabled

func ungrab() -> bool:
	if enabled:
		get_parent().linear_damp = default_linear_damp
		get_parent().angular_damp = default_angular_damp
		get_parent().axis_lock_angular_x = default_axis_lock_angular_x
		get_parent().axis_lock_angular_y = default_axis_lock_angular_y
		get_parent().axis_lock_angular_z = default_axis_lock_angular_z
		is_grabbed = false
		parent_rotation = get_parent().quaternion
		emit_grab_end()
	return enabled

func get_rotate_axis() -> Vector3:
	return parent_rotation * rotate_axis

func emit_grab_begin():
	grab_begin.emit()

func emit_grab_end():
	grab_end.emit()
