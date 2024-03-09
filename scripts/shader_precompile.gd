extends Node3D

signal shaders_compiling(progress: float)
signal shaders_compiled()

@export var enabled := true
var all_materials: Array[Material] = []

func _ready():
	if not enabled or Engine.is_editor_hint():
		queue_free()
		return
	
	for mesh: MeshInstance3D in get_parent().find_children("*", "MeshInstance3D"):
		if mesh.mesh == null:
			continue
		if mesh.mesh is PrimitiveMesh:
			add_material(mesh.mesh.material)
		for i in mesh.mesh.get_surface_count():
			add_material(mesh.mesh.surface_get_material(i))
		for i in mesh.get_surface_override_material_count():
			add_material(mesh.get_surface_override_material(i))
	
	for material in all_materials:
		var mesh := MeshInstance3D.new()
		mesh.mesh = QuadMesh.new()
		add_child(mesh)
	
	for child in get_children():
		if child is MeshInstance3D:
			RenderingServer.instance_set_ignore_culling(child.get_instance(), true)

func add_material(material: Material):
	if material == null:
		return
	if material in all_materials:
		return
	all_materials.append(material)

func _process(delta):
	var progress: float = (%Timer.wait_time - %Timer.time_left) / %Timer.wait_time
	shaders_compiling.emit(progress)

func _on_timer_timeout():
	shaders_compiled.emit()
	queue_free()
