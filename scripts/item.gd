extends Node3D

signal viewed()
signal collected()

func _ready():
	if not Engine.is_editor_hint():
		collected.connect(GameManager.instance.trigger_achievement.bind("collect_all_items"))

func view():
	emit_viewed()

func collect():
	emit_collected()

func emit_viewed():
	viewed.emit()

func emit_collected():
	collected.emit()
