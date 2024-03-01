extends Node3D
class_name ItemScene

static var instance: ItemScene

# TODO: move these to a settings script
@export_range(0.0, 1.0) var mouse_look_sensitivity := 0.3
var mouse_look_speed: float:
	get: return mouse_look_sensitivity * 0.0001
@export_range(0.0, 1.0) var controller_look_sensitivity := 0.6
var controller_look_speed: float:
	get: return controller_look_sensitivity * 0.1
@export_range(0.0, 1.0) var rotating_look_sensitivity := 0.2

@onready var max_camera_distance: float = %CameraPivot/Camera.position.z * 2.0
var min_camera_distance: float = 0.1

func _init():
	instance = self

func _ready():
	child_entered_tree.connect(func(_node): %CameraPivot.transform = Transform3D.IDENTITY)

func _process(delta: float):
	var look := Vector2.ZERO
	if Utils.mouse_focus:
		look += -Input.get_last_mouse_velocity() * mouse_look_speed
	look += Input.get_vector(&"player_look_right", &"player_look_left", &"player_look_down", &"player_look_up") * controller_look_speed

	%CameraPivot.rotation += Vector3(look.y, look.x, 0.0)
	
	var zoom := Input.get_axis(&"item_zoom_out", &"item_zoom_in")
	zoom += float(Input.is_action_just_pressed(&"item_zoom_in")) * 10.0
	zoom -= float(Input.is_action_just_pressed(&"item_zoom_out")) * 10.0
	if zoom > 0.0:
		%CameraPivot/Camera.position.z = move_toward(%CameraPivot/Camera.position.z, min_camera_distance, zoom * delta)
	elif zoom < 0.0:
		%CameraPivot/Camera.position.z = move_toward(%CameraPivot/Camera.position.z, max_camera_distance, -zoom * delta)
	
	if Input.is_action_just_pressed(&"player_action_interact"):
		get_tree().paused = false
