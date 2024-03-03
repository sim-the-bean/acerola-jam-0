extends Node

var mouse_look_sensitivity := 0.3
var controller_look_sensitivity := 0.6
var look_invert_x := false
var look_invert_y := false
var look_invert: Vector2:
	get: return Vector2(-1.0 if look_invert_x else 1.0, -1.0 if look_invert_y else 1.0)
