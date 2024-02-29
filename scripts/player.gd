extends CharacterBody3D

const look_speed := 0.0001

@export var speed := 5.0
@export var jump_velocity := 4.5
@export var mouse_look_speed := 0.3
@export var controller_look_speed := 1.0
@export var grab_speed := 5000.0
@export var grab_angular_speed := 200.0
@export var grab_damp := 10.0
@export var grab_angular_damp := 15.0

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var mouse_focus := false:
	set(value):
		mouse_focus = value
		if mouse_focus:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		else:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
var grabbed: RigidBody3D = null

func _physics_process(delta: float):
	process_movement(delta)
	process_raycast()
	process_grabbed(delta)

func process_movement(delta: float):
	if not is_on_floor():
		velocity.y -= gravity * delta

	if Input.is_action_just_pressed("player_jump") and is_on_floor():
		velocity.y = jump_velocity
	
	if mouse_focus:
		var controller_look = Input.get_vector("player_look_left", "player_look_right", "player_look_up", "player_look_down") * controller_look_speed
		var mouse_look = -Input.get_last_mouse_velocity() * mouse_look_speed
		var look = controller_look if controller_look.length() > 0.0 else mouse_look
		look *= look_speed
		%PlayerCamera.rotate_x(look.y)
		%PlayerCamera.rotation.x = clampf(%PlayerCamera.rotation.x, -PI * 0.5, PI * 0.5)
		rotate_y(look.x)
	elif Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		mouse_focus = true
	
	if Input.is_action_just_pressed(&"ui_cancel"):
		mouse_focus = false
	
	var input_dir = Input.get_vector("player_move_left", "player_move_right", "player_move_forward", "player_move_back")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)

	move_and_slide()

func process_raycast():
	var collider = %PlayerCamera/RayCast.get_collider()
	if grabbed == null and collider != null:
		%PlayerCamera/RayCast/GrabPoint.global_position = %PlayerCamera/RayCast.get_collision_point()
	if Input.is_action_just_pressed(&"player_action_grab"):
		if grabbed != null:
			grabbed.gravity_scale = 1
			grabbed.linear_damp = 1
			grabbed.angular_damp = 1
			grabbed = null
		elif collider != null:
			grabbed = collider
			grabbed.gravity_scale = 0
			grabbed.linear_damp = grab_damp
			grabbed.angular_damp = grab_angular_damp

func process_grabbed(delta: float):
	if grabbed != null:
		var rot_diff = quaternion_from_to(%PlayerCamera, grabbed, %PlayerCamera/RayCast/GrabPoint)
		if absf(rot_diff.get_angle()) > 0.1:
			var torque = rot_diff.get_euler() * Vector3(0, 1, 0)
			grabbed.apply_torque(torque * grab_angular_speed * delta)
		var pos_diff: Vector3 = %PlayerCamera/RayCast/GrabPoint.global_position - grabbed.global_position
		if pos_diff.length() > 0.1:
			grabbed.apply_force(pos_diff * grab_speed * delta)

func quaternion_from_to(pivot: Node3D, from: Node3D, to: Node3D) -> Quaternion:
	var pos_a = from.global_position - pivot.global_position
	var pos_b = to.global_position - pivot.global_position
	return Quaternion(pos_a, pos_b).normalized()
	
