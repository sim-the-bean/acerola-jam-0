@tool
extends Node3D

signal viewed()
signal collected()

var custom_mesh := false

func _ready():
	if not Engine.is_editor_hint():
		collected.connect(GameManager.instance.trigger_achievement.bind("collect_all_items"))

func view():
	emit_viewed()

func collect():
	emit_collected()

func _on_child_entered_tree(node: Node):
	if custom_mesh:
		return
	
	var mesh_node: MeshInstance3D = null
	var col_node: CollisionShape3D = null
	if node is Node3D:
		if node is MeshInstance3D and node != %Mesh:
			mesh_node = node
		if node is CollisionShape3D and node != %Collider:
			col_node = node
		for child in node.find_children("*"):
			if mesh_node == null and child is MeshInstance3D:
				mesh_node = child
			if col_node == null and child is CollisionShape3D:
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
		%Mesh.visible = false
	if col_node != null:
		%Collider.disabled = true

func _on_child_exiting_tree(node):
	if custom_mesh and node is MeshInstance3D and node != %Mesh:
		custom_mesh = false
		%Mesh.visible = true
	if node is CollisionShape3D and node != %Collider:
		%Collider.disabled = false
		
func emit_viewed():
	viewed.emit()

func emit_collected():
	collected.emit()
