extends Node3D

@export var first_scene: PackedScene = preload("res://scenes/test.tscn")

var active_scene: Node3D = null

func _ready():
	switch_scene(first_scene)

func switch_scene(scene: PackedScene):
	if active_scene != null:
		active_scene.queue_free()

	active_scene = scene.instantiate()
	add_child(active_scene)
	var player_marker: Node3D = get_tree().get_first_node_in_group(&"player_marker")
	if player_marker != null:
		%Player.global_transform = player_marker.global_transform
