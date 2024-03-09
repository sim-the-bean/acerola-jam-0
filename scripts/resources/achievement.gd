extends Resource
class_name Achievement

@export var title := ""
@export var description := ""
@export var id := ""
@export var steps := 1
@export var show_progress := true
@export var save_progress := false

var progress := 0:
	set(value):
		progress = clamp(value, 0, steps)
var finished: bool:
	get: return progress == steps
