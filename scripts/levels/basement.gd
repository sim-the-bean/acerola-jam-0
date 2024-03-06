extends Node3D

const black_hole_scene := preload("res://scenes/objects/black_hole.tscn")

func _on_big_red_button_clicked():
	%ReactorSpotLight.light_energy = 0.3
	var timer = create_tween()
	timer.tween_interval(2.0)
	timer.tween_property(%ReactorSpotLight, "flicker_enabled", true, 0.0)
	timer.tween_interval(3.0)
	timer.tween_property(%ReactorSpotLight, "base_light_energy", 2.0, 1.5)
	timer.tween_property(%ReactorSpotLight, "base_light_energy", 0.2, 0.0)
	timer.tween_callback(func():
		var black_hole := black_hole_scene.instantiate()
		black_hole.position = %BlackHoleMarker.position
		black_hole.get_node("Hitbox").gravity = 8
		black_hole.get_node("Hitbox").get_node("CollisionShape3D").shape.radius = 4
		add_child(black_hole))
	timer.tween_interval(2.0)
	timer.tween_callback(%Door.open)
