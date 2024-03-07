extends CharacterBody3D
class_name Player

signal hover_entered(node: Node3D)
signal hover_left(node: Node3D)

enum PositionState {
	NORMAL,
	ROTATING,
	BLACK_HOLE,
	KILLED,
	ITEM_ZOOM,
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
@export var grabbed_rotate_speed := 100.0
@export var jump_buffer_duration := 0.2
@export var killed_rotation_speed := 10.0
@export var item_zoom_speed := 1.0

@export_group("Controls")
var mouse_look_speed: float:
	get: return GameSettings.mouse_look_sensitivity * 0.0001
var controller_look_speed: float:
	get: return GameSettings.controller_look_sensitivity * 0.1
@export_range(0.0, 1.0) var rotating_look_sensitivity := 0.2

@export_group("Physics")
@export var gravity_scale := 1.0

@export_group("Internals")
@export var grab_speed := 5000.0

var gravity_direction: Vector3:
	get: return _gravity_direction
	set(value):
		if position_state == PositionState.NORMAL:
			var new_gravity = value.normalized()
			var new_up = -new_gravity
			var current_rotation = rotation_quaternion
			position_state = PositionState.ROTATING
			previous_rotation = current_rotation
			target_rotation = current_rotation * Quaternion(up_direction, new_up)
			target_up_direction = new_up
			rotation_axis = up_direction.cross(new_up)
			if rotation_axis.is_zero_approx():
				rotation_axis = current_rotation * Vector3.FORWARD
			
			velocity -= velocity * up_direction.abs()
			direction = Vector3.ZERO
			
			_gravity_direction = new_gravity
var _gravity_direction: Vector3
var gravity_strength: float
var gravity: Vector3:
	get: return -up_direction * gravity_strength * gravity_scale
	
var gravity_point := false:
	set(value):
		gravity_point = value
		position_state = PositionState.BLACK_HOLE if gravity_point else PositionState.NORMAL
		if not gravity_point:
			point_gravity_acc = Vector3.ZERO
var gravity_point_unit_distance: float
var gravity_point_center: Vector3
var gravity_point_strength: float
var point_gravity_acc: Vector3

var position_state := PositionState.NORMAL:
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
var rotation_quaternion: Quaternion:
	get: return transform.basis.orthonormalized().get_rotation_quaternion()

var input_allowed := true
var direction := rotation_quaternion * Vector3.FORWARD
var speed := 0.0
var acceleration: float:
	get: return max_speed * acceleration_rate
var super_acceleration: float:
	get: return (super_speed - max_speed) * super_acceleration_rate
var deceleration: float:
	get: return max_speed * deceleration_rate
var jump_buffer := false
var jump_buffer_time := 0.0
var is_walking := false
var was_walking := false

var hovered: Node3D = null
var last_hovered: Node3D = null
var grabbed: RigidBody3D = null
var interactive: Node3D = null

var step_sound_tween: Tween

func _ready():
	_gravity_direction = ProjectSettings.get_setting("physics/3d/default_gravity_vector").normalized()
	gravity_strength = ProjectSettings.get_setting("physics/3d/default_gravity")
	position_state = PositionState.NORMAL
	gravity_field_counter = 0
	
	gravity_point = false
	gravity_point_unit_distance = 0.0
	gravity_point_center = Vector3.ZERO
	gravity_point_strength = 0.0
	point_gravity_acc = Vector3.ZERO

	input_allowed = true
	direction = rotation_quaternion * Vector3.FORWARD
	speed = 0.0
	jump_buffer = false
	jump_buffer_time = 0.0

	hovered = null
	last_hovered = null
	grabbed = null
	interactive = null
	
	Utils.mouse_focus = true
	%HudQuad.visible = true
	%HudQuad.mesh.material.set_shader_parameter("hud_viewport", $HudViewport.get_texture())
	
	if not Engine.is_editor_hint():
		step_sound_tween = create_tween()
		step_sound_tween.set_loops()
		step_sound_tween.tween_interval(0.2)
		step_sound_tween.tween_callback(%StepSound.play)
		step_sound_tween.tween_interval(0.3)
		step_sound_tween.pause()

func on_killing():
	position_state = PositionState.KILLED

func on_killed():
	GameManager.instance.reset()

func _unhandled_input(event: InputEvent):
	%HudViewport.push_input(event)

func _physics_process(delta: float):
	jump_buffer_time -= delta
	match position_state:
		PositionState.NORMAL:
			process_physics(delta)
			process_look(delta)
			process_input(delta)
			process_movement(delta)
			process_raycast(delta)
			process_grabbed(delta)
		PositionState.ITEM_ZOOM:
			process_physics(delta)
			process_movement(delta)
			process_raycast(delta)
			process_item(delta)
		PositionState.ROTATING:
			process_rotation(delta)
			process_physics(delta)
			process_look(delta)
			process_movement(delta)
			process_raycast(delta)
			process_grabbed(delta)
		PositionState.BLACK_HOLE:
			process_bh_physics(delta)
			process_look(delta)
			process_input(delta)
			process_movement(delta)
			process_raycast(delta)
			process_grabbed(delta)
		PositionState.KILLED:
			process_bh_killed(delta)

func process_physics(delta: float):
	if not is_on_floor():
		velocity += gravity * delta

func process_bh_physics(delta: float):
	var center_of_gravity: Vector3 = %Collider.global_position
	var distance := center_of_gravity.distance_to(gravity_point_center)
	var falloff := gravity_point_unit_distance / distance
	falloff *= falloff
	var point_gravity := (gravity_point_center - center_of_gravity).normalized()
	point_gravity *= gravity_point_strength * falloff
	point_gravity_acc += point_gravity * delta

func process_bh_killed(delta: float):
	var offset := global_position - gravity_point_center
	offset = offset.rotated(up_direction, killed_rotation_speed * delta)
	global_position = gravity_point_center + offset

func process_look(_delta: float):
	var look := get_look_vector()
	
	if position_state == PositionState.ROTATING:
		look *= rotating_look_sensitivity
	
	%CameraPivot.rotate_x(look.y)
	%CameraPivot.rotation.x = clampf(%CameraPivot.rotation.x, -PI * 0.5, PI * 0.5)
	rotate(up_direction, look.x)

func process_input(delta: float):
	if Input.is_action_just_pressed(&"player_jump") or (jump_buffer and jump_buffer_time >= 0.0):
		if is_on_floor():
			%JumpSound.play()
			velocity = up_direction * jump_velocity
			jump_buffer = false
		elif not jump_buffer:
			jump_buffer = true
			jump_buffer_time = jump_buffer_duration
	
	var raw_input := call_function(&"get_input_vector") as Vector2
	var input_dir := raw_input if input_allowed else Vector2.ZERO
	var input_direction := rotation_quaternion * Vector3(input_dir.x, 0, input_dir.y)
	input_direction = input_direction.limit_length()
	var new_direction = direction
	var new_speed = speed
	if input_direction:
		var angle := acos(input_direction.dot(rotation_quaternion * Vector3.FORWARD))
		var backwards := clampf((angle - (PI - backwards_angle)) / backwards_angle, 0.0, 1.0)
		if backwards:
			new_speed = move_toward(speed, lerpf(max_speed, backwards_speed, backwards), acceleration * delta)
		elif speed < max_speed:
			new_speed = move_toward(speed, max_speed, acceleration * delta)
		else:
			new_speed = move_toward(speed, super_speed, super_acceleration * delta)
		new_direction = input_direction
		is_walking = is_on_floor()
		step_sound_tween.set_speed_scale(new_speed / max_speed * 2.0)
	else:
		if not input_allowed and not raw_input:
			input_allowed = true
		new_speed = move_toward(speed, 0, deceleration * delta)
		is_walking = false
	direction = direction.lerp(new_direction, 1.0 if is_on_floor() else air_control)
	speed = lerpf(speed, new_speed, 1.0 if is_on_floor() else air_control)
	
	if is_walking and not was_walking:
		step_sound_tween.play()
	elif not is_walking and was_walking:
		step_sound_tween.stop()
	
	match position_state:
		PositionState.BLACK_HOLE:
			velocity = point_gravity_acc + direction * speed
		_:
			velocity = velocity * up_direction.abs() + direction * speed
	was_walking = is_walking

func process_movement(_delta: float):
	move_and_slide()

func process_rotation(delta: float):
	if rotation_weight >= 1.0:
		up_direction = target_up_direction
		position_state = PositionState.NORMAL
	else:
		var angle := previous_rotation.angle_to(target_rotation) * delta * flip_speed
		rotate(rotation_axis, angle)
		up_direction = up_direction.rotated(rotation_axis, angle)
		base_rotation = Quaternion.from_euler(rotation)
		rotation_weight += delta * flip_speed

func process_raycast(delta):
	var collider = %RayCast.get_collider()
	if grabbed == null and interactive == null and collider != hovered:
		if hovered != null:
			if hovered.has_node("HoverComponent"):
				hovered.get_node("HoverComponent").emit_hover_exited()
			hover_left.emit(hovered)
		hovered = collider
		if hovered != null:
			if hovered.has_node("HoverComponent"):
				hovered.get_node("HoverComponent").emit_hover_entered()
			hover_entered.emit(hovered)
			last_hovered = hovered
	if grabbed == null and collider != null:
		%GrabPoint.global_position = %RayCast.get_collision_point()
	if hovered != null:
		if hovered.is_in_group("grabbable"):
			do_grab(delta)
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
		do_grab(delta)
		do_item()

func process_item(_delta: float):
	var look := get_look_vector()
	
	%HoldItemPoint.rotate_y(look.x)
	%HoldItemPoint.rotate_x(look.y)

func do_grab(delta):
	if Input.is_action_just_pressed(&"player_action_grab"):
		if grabbed != null:
			if grabbed.has_node("GrabComponent"):
				if grabbed.get_node("GrabComponent").ungrab():
					grabbed = null
		elif hovered != null:
			if hovered.has_node("GrabComponent"):
				if hovered.get_node("GrabComponent").grab():
					grabbed = hovered
	if Input.is_action_just_pressed(&"player_action_throw"):
		if grabbed != null:
			if grabbed.has_node("GrabComponent"):
				if grabbed.get_node("GrabComponent").ungrab():
					var throw_direction = %CameraPivot.global_transform.basis.get_rotation_quaternion() * Vector3.FORWARD
					grabbed.apply_impulse(throw_direction * throw_strength)
					grabbed = null

func do_item():
	if Input.is_action_just_released(&"player_action_interact"):
		if interactive == null and hovered != null:
			interactive = hovered
			interactive.view()
			interactive.reparent(%HoldItemPoint)
			var tween = create_tween()
			tween.tween_property(interactive, "position", Vector3.ZERO, item_zoom_speed)
			tween.parallel().tween_property(interactive, "quaternion", Quaternion.IDENTITY, item_zoom_speed)
			position_state = PositionState.ITEM_ZOOM
		elif interactive != null:
			interactive.collect()
			interactive.queue_free()
			interactive = null
			position_state = PositionState.NORMAL

func process_grabbed(delta: float):
	if grabbed != null:
		var pos_diff: Vector3 = %GrabPoint.global_position - grabbed.global_position
		if pos_diff:
			grabbed.apply_force(pos_diff * grab_speed * delta)
		
		var rotate_axis := Vector3.UP
		if grabbed.has_node("GrabComponent"):
			rotate_axis = grabbed.get_node("GrabComponent").rotate_axis
		var rotate := 0.0
		rotate -= float(Input.is_action_pressed(&"player_action_rotate_left"))
		rotate += float(Input.is_action_pressed(&"player_action_rotate_right"))
		grabbed.apply_torque(rotate_axis * rotate * grabbed_rotate_speed * delta)

func get_hold_menu_point() -> Node3D:
	return %HoldMenuPoint

func hud_show_hint(hint_type: UiHintComponent.HintType, hud_type: UiHintComponent.HudType, hint: String):
	match hud_type:
		UiHintComponent.HudType.CURSOR_3D: pass
		_: return %Hud.show_hint(hint_type, hud_type, hint)

func hud_hide_hint(hud_type: UiHintComponent.HudType, node: Control):
	match hud_type:
		UiHintComponent.HudType.CURSOR_3D: pass
		_: return %Hud.hide_hint(hud_type, node)

func quaternion_from_to(pivot: Node3D, from: Node3D, to: Node3D) -> Quaternion:
	var pos_a = from.global_position - pivot.global_position
	var pos_b = to.global_position - pivot.global_position
	return Quaternion(pos_a, pos_b).normalized()

func get_input_vector() -> Vector2:
	return Input.get_vector(&"player_move_left", &"player_move_right", &"player_move_forward", &"player_move_back")

func get_look_vector() -> Vector2:
	var look := Vector2.ZERO
	if Utils.mouse_focus:
		look += -Input.get_last_mouse_velocity() * mouse_look_speed
	look += Input.get_vector(&"player_look_right", &"player_look_left", &"player_look_down", &"player_look_up") * controller_look_speed
	
	look *= GameSettings.look_invert
	return look

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
