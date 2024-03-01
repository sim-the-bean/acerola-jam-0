@tool
extends Node3D
class_name BaseZone

@export var effects: Array[BaseEffect] = []:
	set(value):
		effects = value
		for effect in effects:
			if effect != null:
				if effect.changed.is_connected(effect._on_changed):
					effect.changed.disconnect(effect._on_changed)
				effect.changed.connect(effect._on_changed.bind(self))
				effect._on_changed(self)
@export var debug_color: Color = Color.WHITE:
	set(value):
		debug_color = value
		$DebugMesh.mesh.material.albedo_color = Color(debug_color, debug_alpha)
@export_range(0.0, 1.0) var debug_alpha: float = 0.5:
	get: return debug_alpha
	set(value):
		debug_alpha = value
		$DebugMesh.mesh.material.albedo_color = Color(debug_color, debug_alpha)

func _ready():
	if Engine.is_editor_hint():
		if not $Area/Shape.shape.changed.is_connected(debug_set_size):
			$Area/Shape.shape.changed.connect(debug_set_size)
		$DebugMesh.mesh.material.albedo_color = Color(debug_color, debug_alpha)
		debug_set_size()

func debug_set_size():
	$DebugMesh.mesh.size = $Area/Shape.shape.size
	$DebugMesh.position = $Area/Shape.position

func _on_enter(node: Node3D):
	if Engine.is_editor_hint():
		return
	for effect in effects:
		effect._on_enter(node)

func _on_leave(node: Node3D):
	if Engine.is_editor_hint():
		return
	for effect in effects:
		effect._on_leave(node)

func _process(delta: float):
	if Engine.is_editor_hint():
		return
	for node in $Area.get_overlapping_bodies():
		for effect in effects:
			effect._process(node, delta)

func _physics_process(delta: float):
	if Engine.is_editor_hint():
		return
	for node in $Area.get_overlapping_bodies():
		for effect in effects:
			effect._physics_process(node, delta)
