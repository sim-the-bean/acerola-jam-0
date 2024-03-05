@tool
extends Container
class_name UiAchievement

const duration := 5.0

@export var icon: Texture2D:
	get: return %TextureRect.texture
	set(value): %TextureRect.texture = value
@export_placeholder("Achievement title") var title: String:
	get: return "" if %Title.text == "Achievement title" else %Title.text
	set(value):
		if value != "":
			%Title.text = value
		else:
			%Title.text = "Achievement title"
@export_placeholder("Description") var description: String:
	get: return "" if %Description.text == "Description" else %Description.text
	set(value):
		if value != "":
			%Description.text = value
		else:
			%Description.text = "Description"
@export var progress: int = 0:
	get: return %ProgressBar.value
	set(value): %ProgressBar.value = value
@export var steps: int = 1:
	get: return %ProgressBar.max_value
	set(value): %ProgressBar.max_value = value

func _ready():
	if not Engine.is_editor_hint():
		var timer := get_tree().create_timer(duration, false, false, true)
		timer.timeout.connect(queue_free)
