@tool
extends RigidBody3D

signal glitched()
signal unglitched()

const layers_glitched := Layers.grabbable | Layers.glitched
const layers_unglitched := Layers.default | Layers.grabbable | Layers.aoe | Layers.destructible

@export_category("Glitched")
@export var is_glitched := true:
	set(value):
		is_glitched = value
		gravity_scale = 0.0 if is_glitched else 1.0
		if is_glitched:
			if is_inside_tree():
				%MeshGlitched.visible = true
				%MeshOk.visible = false
			collision_layer = layers_glitched | (Layers.destructible if can_destroy else 0)
			collision_mask = Layers.glitched
			emit_glitched()
		else:
			if is_inside_tree():
				%MeshGlitched.visible = false
				%MeshOk.visible = true
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
@export_group("Visuals")
@export var chromatic_aberration_strength := Vector3(0.2, 0.2, 0.2):
	set(value):
		chromatic_aberration_strength = value
		if is_inside_tree():
			%MeshRed.mesh.material.set_shader_parameter("chromatic_aberration_strength", chromatic_aberration_strength * 0.1)
			%MeshGreen.mesh.material.set_shader_parameter("chromatic_aberration_strength", chromatic_aberration_strength * 0.1)
			%MeshBlue.mesh.material.set_shader_parameter("chromatic_aberration_strength", chromatic_aberration_strength * 0.1)
@export_range(0.0, 10.0, 0.1, "or_greater") var glitchiness_amplitude := 1.0:
	set(value):
		glitchiness_amplitude = value
		if is_inside_tree():
			%MeshRed.mesh.material.set_shader_parameter("glitchiness_amplitude", glitchiness_amplitude)
			%MeshGreen.mesh.material.set_shader_parameter("glitchiness_amplitude", glitchiness_amplitude)
			%MeshBlue.mesh.material.set_shader_parameter("glitchiness_amplitude", glitchiness_amplitude)
@export_range(0.0, 10.0, 0.1, "or_greater") var glitchiness_frequency := 1.0:
	set(value):
		glitchiness_frequency = value
		if is_inside_tree():
			%MeshRed.mesh.material.set_shader_parameter("glitchiness_frequency", glitchiness_frequency)
			%MeshGreen.mesh.material.set_shader_parameter("glitchiness_frequency", glitchiness_frequency)
			%MeshBlue.mesh.material.set_shader_parameter("glitchiness_frequency", glitchiness_frequency)
@export_color_no_alpha var color := Color.WHITE:
	set(value):
		color = value
		if is_inside_tree():
			%MeshRed.mesh.material.set_shader_parameter("albedo_color", Color(color, alpha))
			%MeshGreen.mesh.material.set_shader_parameter("albedo_color", Color(color, alpha))
			%MeshBlue.mesh.material.set_shader_parameter("albedo_color", Color(color, alpha))
@export_range(0.0, 1.0) var alpha := 0.75:
	set(value):
		alpha = value
		if is_inside_tree():
			%MeshRed.mesh.material.set_shader_parameter("albedo_color", Color(color, alpha))
			%MeshGreen.mesh.material.set_shader_parameter("albedo_color", Color(color, alpha))
			%MeshBlue.mesh.material.set_shader_parameter("albedo_color", Color(color, alpha))

func set_glitched():
	is_glitched = true

func set_unglitched():
	is_glitched = false

func emit_glitched():
	glitched.emit()

func emit_unglitched():
	unglitched.emit()

