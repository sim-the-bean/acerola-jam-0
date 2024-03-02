@tool
extends ConvexPolygonShape3D
class_name ConeShape3D

@export var top_radius := 1.0:
	set(value):
		top_radius = value
		recalculate()
@export var bottom_radius := 1.0:
	set(value):
		bottom_radius = value
		recalculate()
@export var height := 1.0:
	set(value):
		height = value
		recalculate()
@export var radial_segments := 8:
	set(value):
		radial_segments = value
		recalculate()

func _ready():
	recalculate()

func recalculate():
	var new_points := PackedVector3Array()
	var y_bottom = -height * 0.5
	var y_top = height * 0.5
	for i in radial_segments:
		var angle = float(i) / float(radial_segments) * TAU
		var x = cos(angle)
		var z = sin(angle)
		new_points.append(Vector3(x * bottom_radius, y_bottom, z * bottom_radius))
		new_points.append(Vector3(x * top_radius, y_top, z * top_radius))
	points = new_points
	emit_changed()

func _validate_property(property: Dictionary):
	if property.name == "points":
		property.usage &= ~PROPERTY_USAGE_EDITOR
