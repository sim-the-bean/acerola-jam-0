extends SubViewport

func _ready():
	size = get_window().size
	get_window().size_changed.connect(func(): size = get_window().size)
