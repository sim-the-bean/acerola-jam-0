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
			%Mesh.mesh.material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA_DEPTH_PRE_PASS
			%Mesh.mesh.material.albedo_color.a = 0.5
			collision_layer = layers_glitched | (Layers.destructible if can_destroy else 0)
			collision_mask = Layers.glitched
			emit_glitched()
		else:
			%Mesh.mesh.material.transparency = BaseMaterial3D.TRANSPARENCY_DISABLED
			%Mesh.mesh.material.albedo_color.a = 1.0
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

func set_glitched():
	is_glitched = true

func set_unglitched():
	is_glitched = false

func emit_glitched():
	glitched.emit()

func emit_unglitched():
	unglitched.emit()

