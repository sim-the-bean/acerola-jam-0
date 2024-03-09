extends Node3D
class_name GameManager

signal achievement_got(achievement: Achievement)

static var instance: GameManager

const achievements_path := "user://achievements.cfg"

@export var player_scene: PackedScene = preload("res://scenes/objects/player.tscn")
@export var main_menu_scene: PackedScene = preload("res://scenes/main_menu.tscn")
@export var game_menu_scene: PackedScene = preload("res://scenes/game_menu.tscn")
@export var test_scene: PackedScene = preload("res://scenes/test.tscn")
@export var first_scene: PackedScene = preload("res://scenes/levels/basement.tscn")
@export var achievements: Array[Achievement]

var menu: Newspaper = null
var player: Player = null
var active_scene: PackedScene
var active_scene_node: Node3D = null
var game_menu_node: Node3D = null
var in_main_menu := false
var environment: WorldEnvironment
var checkpoint: Checkpoint = null

var _achievements: Dictionary = {}
var achievement_file := ConfigFile.new()

func _init():
	instance = self

func _ready():
	switch_to_main_menu()
	if not Engine.is_editor_hint():
		achievement_file.load(achievements_path)
		for a in achievements:
			var progress = achievement_file.get_value("Achievements", a.id, 0)
			_achievements[a.id] = a.duplicate()
			_achievements[a.id].progress = progress

func _process(delta):
	if Input.is_action_just_pressed(&"game_pause"):
		if in_main_menu:
			menu.previous_page()
		else:
			toggle_pause()

func switch_to_main_menu():
	if player != null:
		player.queue_free()
		player = null
	switch_scene(main_menu_scene)
	menu = active_scene_node.get_node(^"Newspaper")
	in_main_menu = true

func new_game():
	switch_scene(first_scene, true)
	in_main_menu = false

func play_test():
	switch_scene(test_scene, true)
	in_main_menu = false

func save_game():
	pass

func continue_game():
	pass

func toggle_pause():
	if get_tree().paused:
		unpause()
	else:
		pause()

func pause():
	get_tree().paused = true
	if game_menu_node == null:
		game_menu_node = game_menu_scene.instantiate()
		player.get_hold_menu_point().add_child(game_menu_node)
		menu = game_menu_node.get_node(^"Newspaper")
	game_menu_node.enabled = true
	Utils.mouse_focus = false

func unpause():
	get_tree().paused = false
	if game_menu_node != null:
		game_menu_node.enabled = false
	Utils.mouse_focus = true

func quit():
	get_tree().root.propagate_notification(NOTIFICATION_WM_CLOSE_REQUEST)
	call_deferred(&"force_quit")

func force_quit():
	get_tree().quit()

func switch_scene(scene: PackedScene, reset_player := false, reset_checkpoint := true):
	if active_scene_node != null:
		active_scene_node.queue_free()
	
	if reset_player:
		if player == null:
			player = player_scene.instantiate()
			%GameRoot.add_child(player)
		else:
			player._ready()
	
	active_scene = scene
	active_scene_node = scene.instantiate()
	%GameRoot.add_child(active_scene_node)
	environment = active_scene_node.get_node_or_null("WorldEnvironment")
	
	if reset_checkpoint or checkpoint == null:
		var checkpoints = get_tree().get_nodes_in_group(&"checkpoint")
		checkpoint = null
		for cp in checkpoints:
			if checkpoint == null or cp.checkpoint_priority < checkpoint.checkpoint_priority:
				checkpoint = cp
	if player != null and checkpoint != null:
		player.transform = checkpoint.spawn_point
	get_tree().paused = false

func reset_to_checkpoint():
	if player != null and checkpoint != null:
		player._ready()
		player.transform = checkpoint.spawn_point
		checkpoint.reset_to()

func reset():
	switch_scene(active_scene, true, true)

func trigger_achievement(id: String):
	var achievement: Achievement = null
	if _achievements.has(id):
		achievement = _achievements[id]
	else:
		for a in achievements:
			if a.id == id:
				achievement = a.duplicate()
				break
	if achievement == null:
		printerr("Achievement {0} not found".format([id]))
		return
	if not achievement.finished:
		achievement.progress += 1
		if achievement.finished or achievement.show_progress:
			achievement_got.emit(achievement)
	_achievements[id] = achievement
	if achievement.finished or achievement.save_progress:
		achievement_file.set_value("Achievements", id, achievement.progress)
		achievement_file.save(achievements_path)
