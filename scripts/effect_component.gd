extends Node
class_name EffectComponent

var saved_vars: Dictionary
var replaced_funs: Dictionary

func replace_variable(key: StringName, value: Variant):
	if not saved_vars.has(key):
		saved_vars[key] = get_parent().get(key)
	get_parent().set(key, value)

func replace_function(key: String, value: Callable):
	replaced_funs[key] = value

func reset_variable(key: StringName):
	if saved_vars.has(key):
		get_parent().set(key, saved_vars[key])
		saved_vars.erase(key)

func reset_function(key: String):
	replaced_funs.erase(key)

func get_value(key: StringName, default: Variant = null) -> Variant:
	return saved_vars.get(key, default)

func get_function(key: String, default: Callable) -> Callable:
	return replaced_funs.get(key, default)
