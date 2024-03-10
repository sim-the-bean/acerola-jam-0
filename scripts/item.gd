@tool
extends Node3D
class_name CollectibleItem

signal viewed()
signal collected()

func _ready():
	if not Engine.is_editor_hint():
		collected.connect(GameManager.instance.trigger_achievement.bind("collect_all_items"))

func view():
	emit_viewed()
	%Page/OpenSound.play()

func collect():
	emit_collected()
	%Page/CloseSound.play()

func emit_viewed():
	viewed.emit()

func emit_collected():
	collected.emit()
