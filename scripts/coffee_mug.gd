@tool
extends Glitched
class_name CoffeeMug

@export var coffee_ball_scene: PackedScene = preload("res://scenes/objects/coffee_ball.tscn")

var flipped := false

func _process(_delta):
	if Engine.is_editor_hint():
		return
	if not flipped and acos((quaternion * Vector3.UP).dot(Vector3.DOWN)) < deg_to_rad(30):
		flipped = true
		var coffee_ball := coffee_ball_scene.instantiate()
		coffee_ball.translate(global_position)
		get_parent_node_3d().add_child(coffee_ball)
		%Coffee.visible = false
