@tool
extends StaticBody3D

signal destroyed()

@export var is_destroyed := false:
	get: return _is_destroyed
	set(value):
		if Engine.is_editor_hint():
			if value:
				force_destroy()
			else:
				force_undestroy()
		_is_destroyed = value
@export var minimum_momentum := 7.0

var _is_destroyed := false

func destroy(node: Node3D = null):
	if _is_destroyed:
		return
	
	if node != null and node is RigidBody3D:
		if node.linear_velocity.length() * node.mass < minimum_momentum:
			return
	
	force_destroy()

func force_destroy():
	_is_destroyed = true
	%MeshOk.visible = false
	%MeshBroken.visible = true
	emit_destroyed()

func force_undestroy():
	_is_destroyed = false
	%MeshOk.visible = true
	%MeshBroken.visible = false

func emit_destroyed():
	destroyed.emit()
