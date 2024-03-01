extends Node3D

@export var effects: Array[BaseEffect] = []

func _on_enter(node: Node3D):
	for effect in effects:
		effect._on_enter(node)

func _on_leave(node: Node3D):
	for effect in effects:
		effect._on_leave(node)

func _process(delta: float):
	for node in %Area.get_overlapping_bodies():
		for effect in effects:
			effect._process(node, delta)
