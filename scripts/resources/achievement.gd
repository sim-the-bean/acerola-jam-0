extends Resource
class_name Achievement

@export var title := ""
@export var description := ""
@export var id := ""
@export var steps := 1

var counter := 0:
	set(value):
		counter = clamp(value, 0, steps)
var finished: bool:
	get: return counter == steps
