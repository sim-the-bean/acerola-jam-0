extends Node3D

const black_hole_scene := preload("res://scenes/objects/black_hole.tscn")

@onready var boxes_to_glitch: Array[Glitched] = [
	$IntroRoom/SmallBox6, $IntroRoom/SmallBox7, $IntroRoom/SmallBox8,
]
@onready var wait_button_timer: Timer = %BigRedButtonAchievementTimer

func _ready():
	$LevelGeometry/CyclopsBlocks/Ceilings.visible = true
	wait_button_timer.timeout.connect(GameManager.instance.trigger_achievement.bind("wait_button"))
	get_tree().paused = true

func _on_big_red_button_clicked():
	wait_button_timer.stop()
	GameManager.instance.trigger_achievement("press_10_times")
	%ReactorSpotLight.light_energy = 1.0
	var timer = create_tween()
	timer.tween_interval(1.0)
	timer.tween_callback(%Aberratron/AnimationPlayer.play.bind("Spin"))
	timer.tween_callback(%Aberratron/AudioStreamPlayer3D.play)
	timer.tween_property(%ReactorSpotLight, "flicker_enabled", true, 0.0)
	timer.tween_interval(4.0)
	timer.tween_property(%ReactorSpotLight, "base_light_energy", 5.0, 2.6)
	timer.tween_property(%ReactorSpotLight, "base_light_energy", 0.2, 0.1)
	timer.tween_callback(func():
		for box in boxes_to_glitch:
			box.is_glitched = true
			box.apply_impulse(Vector3(randf_range(-0.1, 0.1), randf_range(0.3, 0.5), randf_range(-0.1, 0.1)))
			box.apply_torque_impulse(Vector3(randf_range(-0.1, 0.1), randf_range(-0.1, 0.1), randf_range(-0.1, 0.1)))
		
		var black_hole := black_hole_scene.instantiate()
		black_hole.position = %BlackHoleMarker.position
		black_hole.scale = Vector3(0.01, 0.01, 0.01)
		black_hole.get_node("Hitbox").gravity = 8
		black_hole.get_node("Hitbox").get_node("CollisionShape3D").shape.radius = 4
		add_child(black_hole)
		var black_hole_tween := black_hole.create_tween()
		black_hole_tween.tween_property(black_hole, "scale", Vector3.ONE, 1.0).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO))
	timer.tween_interval(2.5)
	timer.tween_callback(%Door.open)

func _on_big_red_button_clicked_locked():
	GameManager.instance.trigger_achievement("press_10_times")

func _on_door_clicked():
	GameManager.instance.trigger_achievement("open_doors")

func _on_companion_cube_achievement_trigger_body_entered(body):
	if body.name == "CompanionCube":
		GameManager.instance.trigger_achievement("companion_cube")

func _on_shaders_compiled():
	GameManager.instance.unpause()

func _on_shaders_compiling(progress):
	pass

func _on_end_area_player_entered(player):
	GameManager.instance.switch_to_main_menu()
