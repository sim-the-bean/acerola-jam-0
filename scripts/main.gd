extends Node3D
class_name GameManager

static var instance: GameManager

@export var first_scene: PackedScene = preload("res://scenes/test.tscn")

var current_scene: PackedScene
var active_scene: Node3D = null
@onready var default_player_transform: Transform3D = %Player.global_transform

func _init():
	instance = self

func _ready():
	switch_scene(first_scene)

func switch_scene(scene: PackedScene, reset_player := false):
	if active_scene != null:
		active_scene.free()
	
	%Player.global_transform = default_player_transform
	current_scene = scene
	active_scene = scene.instantiate()
	add_child(active_scene)
	var player_marker: Node3D = get_tree().get_first_node_in_group(&"player_marker")
	if player_marker != null:
		%Player.global_transform = player_marker.global_transform
		default_player_transform = player_marker.global_transform
	if reset_player:
		%Player._ready()

func reset():
	call_deferred("switch_scene", current_scene, true)
