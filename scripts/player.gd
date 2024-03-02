extends CharacterBody3D
class_name Player

signal hover_entered(node: Node3D)
signal hover_left(node: Node3D)

enum PositionState {
	Normal,
	Rotating,
}

@export_category("Player")
@export_group("Movement")
@export var max_speed := 5.0
@export var super_speed := 7.0
@export var backwards_speed := 2.5
@export_range(0.0, 180.0, 5.0, "radians_as_degrees") var backwards_angle := deg_to_rad(120.0)
@export_range(0.0, 10.0, 0.05, "or_greater") var acceleration_rate := 1.2
@export_range(0.0, 10.0, 0.05, "or_greater") var super_acceleration_rate := 0.15
@export_range(0.0, 10.0, 0.05, "or_greater") var deceleration_rate := 3.0
@export var jump_velocity := 4.5
@export var air_control := 0.05
@export var flip_speed := 1.5
@export var throw_strength := 10.0
@export var jump_buffer_duration := 0.2

@export_group("Controls")
@export_range(0.0, 1.0) var mouse_look_sensitivity := 0.3
var mouse_look_speed: float:
	get: return mouse_look_sensitivity * 0.0001
@export_range(0.0, 1.0) var controller_look_sensitivity := 0.6
var controller_look_speed: float:
	get: return controller_look_sensitivity * 0.1
@export_range(0.0, 1.0) var rotating_look_sensitivity := 0.2

@export_group("Physics")
@export var gravity_scale := 1.0

@export_group("Internals")
@export var grab_speed := 5000.0
@export var grab_angular_speed := 200.0
@export var grab_damp := 10.0
@export var grab_angular_damp := 15.0

var gravity_direction: Vector3 = ProjectSettings.get_setting("physics/3d/default_gravity_vector").normalized():
	set(value):
		if position_state == PositionState.Normal:
			var new_gravity = value.normalized()
			var new_up = -new_gravity
			var current_rotation = transform.basis.get_rotation_quaternion()
			position_state = PositionState.Rotating
			previous_rotation = current_rotation
			target_rotation = current_rotation * Quaternion(up_direction, new_up)
			target_up_direction = new_up
			rotation_axis = up_direction.cross(new_up)
			if rotation_axis.is_zero_approx():
				rotation_axis = current_rotation * Vector3.FORWARD
			
			velocity -= velocity * up_direction.abs()
			direction = Vector3.ZERO
			
			gravity_direction = new_gravity
var gravity_strength: float = ProjectSettings.get_setting("physics/3d/default_gravity")
var gravity: Vector3:
	get: return -up_direction * gravity_strength * gravity_scale

var position_state := PositionState.Normal:
	set(value):
		position_state = value
		rotation_weight = 0.0
var gravity_field_counter := 0
var previous_rotation := Quaternion.IDENTITY:
	set(value):
		previous_rotation = value.normalized()
var target_rotation := Quaternion.IDENTITY:
	set(value):
		target_rotation = value.normalized()
var target_up_direction := up_direction
var rotation_axis := Vector3.ZERO
var base_rotation := Quaternion.from_euler(rotation)
var rotation_weight := 0.0

var input_allowed := true
var direction := transform.basis.get_rotation_quaternion() * Vector3.FORWARD
var speed := 0.0
var acceleration: float:
	get: return max_speed * acceleration_rate
var super_acceleration: float:
	get: return (super_speed - max_speed) * super_acceleration_rate
var deceleration: float:
	get: return max_speed * deceleration_rate
var jump_buffer := false
var jump_buffer_time := 0.0

var hovered: Node3D = null
var last_hovered: Node3D = null
var grabbed: RigidBody3D = null
var interactive: Node3D = null

func _ready():
	%PlayerCamera/ItemZoomViewport/ItemZoomPostProcess.visible = false

func _physics_process(delta: float):
	jump_buffer_time -= delta
	match position_state:
		PositionState.Normal:
			process_physics(delta)
			process_look(delta)
			process_input(delta)
			process_movement(delta)
			process_raycast()
			process_grabbed(delta)
		PositionState.Rotating:
			process_rotation(delta)
			process_physics(delta)
			process_look(delta)
			process_movement(delta)
			process_raycast()
			process_grabbed(delta)

func process_physics(delta: float):
	if not is_on_floor():
		velocity += gravity * delta

func process_look(_delta: float):
	var look := Vector2.ZERO
	if Utils.mouse_focus:
		look += -Input.get_last_mouse_velocity() * mouse_look_speed
	look += Input.get_vector(&"player_look_right", &"player_look_left", &"player_look_down", &"player_look_up") * controller_look_speed
	
	if position_state == PositionState.Rotating:
		look *= rotating_look_sensitivity
	
	%PlayerCamera.rotate_x(look.y)
	%PlayerCamera.rotation.x = clampf(%PlayerCamera.rotation.x, -PI * 0.5, PI * 0.5)
	rotate(up_direction, look.x)

func process_input(delta: float):
	if Input.is_action_just_pressed(&"player_jump") or (jump_buffer and jump_buffer_time >= 0.0):
		if is_on_floor():
			velocity = up_direction * jump_velocity
			jump_buffer = false
		elif not jump_buffer:
			jump_buffer = true
			jump_buffer_time = jump_buffer_duration
	
	if not Utils.mouse_focus and Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		Utils.mouse_focus = true
	
	if Input.is_action_just_pressed(&"ui_cancel"):
		Utils.mouse_focus = false
	
	var raw_input := call_function(&"get_input_vector") as Vector2
	var input_dir := raw_input if input_allowed else Vector2.ZERO
	var input_direction := transform.basis.get_rotation_quaternion() * Vector3(input_dir.x, 0, input_dir.y)
	input_direction = input_direction.limit_length()
	var new_direction = direction
	var new_speed = speed
	if input_direction:
		var angle := acos(input_direction.dot(transform.basis.get_rotation_quaternion() * Vector3.FORWARD))
		var backwards := clampf((angle - (PI - backwards_angle)) / backwards_angle, 0.0, 1.0)
		if backwards:
			new_speed = move_toward(speed, lerpf(max_speed, backwards_speed, backwards), acceleration * delta)
		elif speed < max_speed:
			new_speed = move_toward(speed, max_speed, acceleration * delta)
		else:
			new_speed = move_toward(speed, super_speed, super_acceleration * delta)
		new_direction = input_direction
	else:
		if not input_allowed and not raw_input:
			input_allowed = true
		new_speed = move_toward(speed, 0, deceleration * delta)
	direction = direction.lerp(new_direction, 1.0 if is_on_floor() else air_control)
	speed = lerpf(speed, new_speed, 1.0 if is_on_floor() else air_control)
	
	velocity = velocity * up_direction.abs() + direction * speed

func process_movement(_delta: float):
	move_and_slide()

func process_rotation(delta: float):
	if rotation_weight >= 1.0:
		up_direction = target_up_direction
		position_state = PositionState.Normal
	else:
		var angle := previous_rotation.angle_to(target_rotation) * delta * flip_speed
		rotate(rotation_axis, angle)
		up_direction = up_direction.rotated(rotation_axis, angle)
		base_rotation = Quaternion.from_euler(rotation)
		rotation_weight += delta * flip_speed

func process_raycast():
	var collider = %PlayerCamera/RayCast.get_collider()
	if collider != hovered:
		if hovered != null:
			hover_left.emit(hovered)
		hovered = collider
		hover_entered.emit(hovered)
		if hovered != null:
			last_hovered = hovered
	if grabbed == null and collider != null:
		%PlayerCamera/RayCast/GrabPoint.global_position = %PlayerCamera/RayCast.get_collision_point()
	if hovered != null:
		if hovered.is_in_group("grabbable"):
			do_grab()
		if hovered.is_in_group("item"):
			do_item()
		if hovered.is_in_group("button"):
			var button := hovered
			if Input.is_action_just_pressed(&"player_action_interact"):
				button.click()
				hover_left.connect(func(_node): button.unclick(), CONNECT_ONE_SHOT)
			if Input.is_action_just_released(&"player_action_interact"):
				button.unclick()
	else:
		do_grab()

func do_grab():
	if Input.is_action_just_pressed(&"player_action_grab"):
		if grabbed != null:
			grabbed.linear_damp = 1
			grabbed.angular_damp = 1
			grabbed = null
		elif hovered != null:
			grabbed = hovered
			grabbed.linear_damp = grab_damp
			grabbed.angular_damp = grab_angular_damp
	if Input.is_action_just_pressed(&"player_action_throw"):
		if grabbed != null:
			var throw_direction = %PlayerCamera.global_transform.basis.get_rotation_quaternion() * Vector3.FORWARD
			grabbed.apply_impulse(throw_direction * throw_strength)
			grabbed.linear_damp = 1
			grabbed.angular_damp = 1
			grabbed = null

func do_item():
	if Input.is_action_just_released(&"player_action_interact"):
		if interactive == null:
			%PlayerCamera/ItemZoomViewport/ItemZoomPostProcess.global_transform = %PlayerCamera.global_transform
			%PlayerCamera/ItemZoomViewport/ItemZoomPostProcess.visible = true
			interactive = hovered.duplicate()
			interactive.transform = Transform3D.IDENTITY
			ItemScene.instance.add_child(interactive)
			interactive.tree_exiting.connect(func(): hovered.queue_free())
			get_tree().paused = true
		else:
			%PlayerCamera/ItemZoomViewport/ItemZoomPostProcess.visible = false
			interactive.queue_free()
			interactive = null

func process_grabbed(delta: float):
	if grabbed != null:
		var rot_diff = quaternion_from_to(%PlayerCamera, grabbed, %PlayerCamera/RayCast/GrabPoint)
		if rot_diff:
			var torque = rot_diff.get_euler() * Vector3(0, 1, 0)
			grabbed.apply_torque(torque * grab_angular_speed * delta)
		
		var pos_diff: Vector3 = %PlayerCamera/RayCast/GrabPoint.global_position - grabbed.global_position
		if pos_diff:
			grabbed.apply_force(pos_diff * grab_speed * delta)

func quaternion_from_to(pivot: Node3D, from: Node3D, to: Node3D) -> Quaternion:
	var pos_a = from.global_position - pivot.global_position
	var pos_b = to.global_position - pivot.global_position
	return Quaternion(pos_a, pos_b).normalized()

func get_input_vector() -> Vector2:
	return Input.get_vector(&"player_move_left", &"player_move_right", &"player_move_forward", &"player_move_back")

func get_effect_component() -> EffectComponent:
	return %EffectComponent

func get_function(key: StringName) -> Callable:
	return get_effect_component().get_function(key, get(key))

func call_function(key: StringName, args: Array = []) -> Variant:
	var function = get_function(key)
	if function == null:
		return null
	else:
		if function != get(key):
			args = args.duplicate()
			args.insert(0, self)
		var result = function.callv(args)
		return result
