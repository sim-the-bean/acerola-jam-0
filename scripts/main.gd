extends Node3D
class_name GameManager

static var instance: GameManager

@export var player_scene: PackedScene = preload("res://scenes/objects/player.tscn")
@export var menu_scene: PackedScene = preload("res://scenes/menu.tscn")
@export var first_scene: PackedScene = preload("res://scenes/test.tscn")

var player: Player = null
var active_scene: PackedScene
var active_scene_node: Node3D = null
var default_player_transform: Transform3D

func _init():
	instance = self

func _ready():
	switch_scene(menu_scene)

func new_game():
	switch_scene(first_scene, true)

func continue_game():
	pass

func quit():
	get_tree().root.propagate_notification(NOTIFICATION_WM_CLOSE_REQUEST)
	call_deferred(&"force_quit")

func force_quit():
	get_tree().quit()

func switch_scene(scene: PackedScene, reset_player := false):
	if active_scene_node != null:
		active_scene_node.queue_free()
	
	active_scene = scene
	active_scene_node = scene.instantiate()
	add_child(active_scene_node)
	
	var add_player_to_scene := false
	if reset_player:
		if player == null:
			add_player_to_scene = true
			player = player_scene.instantiate()
		else:
			player._ready()
		
	var player_marker: Node3D = get_tree().get_first_node_in_group(&"player_marker")
	if player_marker != null:
		player.transform = player_marker.transform
		default_player_transform = player_marker.transform
	
	if add_player_to_scene:
		add_child(player)

func reset():
	switch_scene(active_scene, true)
