extends "res://scripts/player_only_area.gd"
class_name Checkpoint

signal reset()

@export_category("Checkpoint")
@export var checkpoint_priority := 0
@export var components: Array[CheckpointComponent] = []

@onready var marker: Marker3D = get_node_or_null("PlayerMarker")

var spawn_point: Transform3D:
	get: return marker.global_transform if marker != null else global_transform

func reset_to():
	for component in components:
		component.reset()
	reset.emit()

func _on_player_entered(player: Player):
	if GameManager.instance.checkpoint == null or checkpoint_priority > GameManager.instance.checkpoint.checkpoint_priority:
		GameManager.instance.checkpoint = self
