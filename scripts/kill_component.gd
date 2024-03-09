extends Node

signal killing()
signal killed()

const kill_y := -100

@export var kill_duration := 0.4
@export var killed_interval := 0.0
@export var scale_on_kill := false
@export var scale_target: NodePath
@export var free_on_killed := true
@export var disable_on_killed := false
@export var unkillable_duration := 0.0

var is_killing := false
var unkillable := false

func _process(delta):
	if get_parent().global_position.y < kill_y:
		kill()

func kill():
	if is_killing or unkillable:
		return
	
	is_killing = true
	emit_killing()
	
	var tween = create_tween()
	if scale_on_kill:
		tween.tween_property(get_node(scale_target), "scale", Vector3(0.0, 0.0, 0.0), kill_duration)
	tween.tween_interval(killed_interval)
	tween.tween_callback(emit_killed)
	if free_on_killed:
		tween.tween_callback(get_parent().queue_free)
	elif disable_on_killed:
		tween.tween_property(get_parent(), "visible", false, 0.0)
		tween.tween_property(get_parent(), "process_mode", Node.PROCESS_MODE_DISABLED, 0.0)
	else:
		tween.tween_property(self, "is_killing", false, 0.0)
		if unkillable_duration > 0.0:
			tween.tween_property(self, "unkillable", true, 0.0)
			tween.tween_interval(unkillable_duration)
			tween.tween_property(self, "unkillable", false, 0.0)

func emit_killing():
	killing.emit()

func emit_killed():
	killed.emit()
