@tool
extends RigidBody3D
class_name Glitched

signal glitched()
signal unglitched()

const layers_glitched := Layers.grabbable | Layers.glitched
const layers_unglitched := Layers.default | Layers.grabbable | Layers.aoe | Layers.destructible | Layers.glitched

@export_category("Glitched")
@export var can_be_glitched := false:
	set(value):
		can_be_glitched = value
		if not can_be_glitched: is_glitched = false
@export var is_glitched := false:
	set(value):
		is_glitched = value and can_be_glitched
		gravity_scale = 0.0 if is_glitched else 1.0
		if is_glitched:
			if mesh_ok_node != null:
				for i in mesh_ok_node.get_surface_override_material_count():
					mesh_ok_node.set_surface_override_material(i, glitched_material)
			collision_layer = layers_glitched | (Layers.destructible if can_destroy else 0)
			collision_mask = Layers.glitched
			emit_glitched()
		else:
			if mesh_ok_node != null:
				for i in mesh_ok_node.get_surface_override_material_count():
					mesh_ok_node.set_surface_override_material(i, null)
			collision_layer = layers_unglitched
			collision_mask = Layers.default
			emit_unglitched()
@export var can_destroy := false:
	set(value):
		can_destroy = value
		if can_destroy:
			collision_layer |= Layers.destructible
		else:
			collision_layer &= ~Layers.destructible
@export var break_on_impact := false:
	set(value):
		break_on_impact = value
		%KillBox.monitoring = break_on_impact
@export var decal_scene: PackedScene = null
@export_group("Glitched visuals")
@export var chromatic_aberration_strength := Vector3(0.2, 0.2, 0.2):
	set(value):
		chromatic_aberration_strength = value
		if is_inside_tree():
			glitched_material.set_shader_parameter("chromatic_aberration_strength", chromatic_aberration_strength * 0.1)
			glitched_material.next_pass.set_shader_parameter("chromatic_aberration_strength", chromatic_aberration_strength * 0.1)
			glitched_material.next_pass.next_pass.set_shader_parameter("chromatic_aberration_strength", chromatic_aberration_strength * 0.1)
@export_range(0.0, 10.0, 0.1, "or_greater") var glitchiness_amplitude := 1.0:
	set(value):
		glitchiness_amplitude = value
		if is_inside_tree():
			glitched_material.set_shader_parameter("glitchiness_amplitude", glitchiness_amplitude)
			glitched_material.next_pass.set_shader_parameter("glitchiness_amplitude", glitchiness_amplitude)
			glitched_material.next_pass.next_pass.set_shader_parameter("glitchiness_amplitude", glitchiness_amplitude)
@export_range(0.0, 10.0, 0.1, "or_greater") var glitchiness_frequency := 1.0:
	set(value):
		glitchiness_frequency = value
		if is_inside_tree():
			glitched_material.set_shader_parameter("glitchiness_frequency", glitchiness_frequency)
			glitched_material.next_pass.set_shader_parameter("glitchiness_frequency", glitchiness_frequency)
			glitched_material.next_pass.next_pass.set_shader_parameter("glitchiness_frequency", glitchiness_frequency)
@export_color_no_alpha var color := Color.WHITE:
	set(value):
		color = value
		if is_inside_tree():
			glitched_material.set_shader_parameter("albedo_color", Color(color, alpha))
			glitched_material.next_pass.set_shader_parameter("albedo_color", Color(color, alpha))
			glitched_material.next_pass.next_pass.set_shader_parameter("albedo_color", Color(color, alpha))
@export_range(0.0, 1.0) var alpha := 0.75:
	set(value):
		alpha = value
		if is_inside_tree():
			glitched_material.set_shader_parameter("albedo_color", Color(color, alpha))
			glitched_material.next_pass.set_shader_parameter("albedo_color", Color(color, alpha))
			glitched_material.next_pass.next_pass.set_shader_parameter("albedo_color", Color(color, alpha))
@export var glitched_material: ShaderMaterial

var mesh_ok_node: MeshInstance3D = null
var custom_mesh := false

func _ready():
	if mesh_ok_node == null: mesh_ok_node = %Mesh

func set_glitched():
	is_glitched = true

func set_unglitched():
	is_glitched = false

func _physics_process(delta):
	if linear_velocity:
		%RayCast.target_position = linear_velocity.normalized()

func _on_kill_box_body_entered(body):
	destroy()

func destroy():
	if break_on_impact:
		if decal_scene != null:
			var decal_position := position
			if %RayCast.is_colliding():
				decal_position = %RayCast.get_collision_point()
			var decal = decal_scene.instantiate()
			decal.translate(decal_position)
			get_parent_node_3d().add_child(decal)
		if %LandSound != null:
			%LandSound.play()
			%LandSound.finished.connect(%LandSound.queue_free)
			%LandSound.reparent(get_parent())
		queue_free()

func emit_glitched():
	glitched.emit()

func emit_unglitched():
	unglitched.emit()

func _on_child_entered_tree(node: Node):
	if custom_mesh:
		return
	
	var mesh_node: MeshInstance3D = null
	var col_node: CollisionShape3D = null
	if node is Node3D:
		if node is MeshInstance3D and node != %Mesh:
			mesh_node = node
		if node is CollisionShape3D and node != %Collider and node.get_parent() != %KillBox:
			col_node = node
		for child in node.find_children("*"):
			if mesh_node == null and child is MeshInstance3D:
				mesh_node = child
			if col_node == null and child is CollisionShape3D and child.get_parent() != %KillBox:
				col_node = child
			if mesh_node != null and col_node != null:
				break
		if col_node != null and col_node != node:
			var reparent_col = func(): 
				col_node.reparent(self)
				for child in node.find_children("*", "CollisionObject3D"):
					child.queue_free()
			reparent_col.call_deferred()
	
	if mesh_node != null:
		custom_mesh = true
		mesh_ok_node = mesh_node
		if is_glitched:
			for i in mesh_ok_node.get_surface_override_material_count():
				mesh_ok_node.set_surface_override_material(i, glitched_material)
		else:
			for i in mesh_ok_node.get_surface_override_material_count():
				mesh_ok_node.set_surface_override_material(i, null)
		%Mesh.visible = false
		$KillComponent.scale_target = $KillComponent.get_path_to(mesh_ok_node)
	if col_node != null:
		%Collider.disabled = true
		%Collider.visible = false

func _on_child_exiting_tree(node):
	if custom_mesh and node == mesh_ok_node and node != %Mesh:
		mesh_ok_node = %Mesh
		custom_mesh = false
		if is_glitched:
			for i in mesh_ok_node.get_surface_override_material_count():
				mesh_ok_node.set_surface_override_material(i, glitched_material)
		else:
			for i in mesh_ok_node.get_surface_override_material_count():
				mesh_ok_node.set_surface_override_material(i, null)
		$KillComponent.scale_target = $KillComponent.get_path_to(mesh_ok_node)
	if node is CollisionShape3D and node != %Collider and node.get_parent() != %KillBox:
		%Collider.disabled = false
		%Collider.visible = true

func _validate_property(property):
	if property.name == "can_be_glitched":
		property.usage |= PROPERTY_USAGE_UPDATE_ALL_IF_MODIFIED
	if not can_be_glitched:
		match property.name:
			"is_glitched", "chromatic_aberration_strength", "chromatic_aberration_strength", \
				"glitchiness_amplitude", "glitchiness_frequency", "color", "alpha":
					property.usage &= ~PROPERTY_USAGE_EDITOR

func _on_body_entered(body):
	var velocity: float = max(linear_velocity.length(), body.linear_velocity.length() if body is RigidBody3D else 0.0)
	if velocity < 0.5:
		return
	var volume: float = clamp(velocity / 10.0, 0.0, 1.0) * 2.0 - 1.0
	%LandSound.volume_db = volume * 20 - 10
	%LandSound.play()
