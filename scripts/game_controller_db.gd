extends Node

enum GameControllerType {
	OTHER,
	XBOX,
	PLAYSTATION,
	SWITCH,
	STEAM,
}

#const db := "res://resources/gamecontrollerdb.txt"
#
#var text: String
#var dict: Dictionary
#
#func _init():
	#var file := FileAccess.open(db, FileAccess.READ)
	#text = file.get_as_text(true)
	#file.close()
	#
	#dict = {}
	#var all_lines := text.split('\n')
	#for line in all_lines:
		#if not line.is_empty() and not line.begins_with("#"):
			#var values := line.split(",")
			#dict[values[0]] = {
				#"id": values[0],
				#"name": values[1],
			#}
#
#func get_type_by_device(device_id := 0) -> GameControllerType:
	#return get_type_by_guid(Input.get_joy_guid(device_id))
#
#func get_type_by_guid(guid: String) -> GameControllerType:
	#if dict.has(guid):
		#var name: String = dict[guid].name.to_lower()
		#if name.contains("xbox") or name.contains("series") or name.contains("microsoft"):
			#return GameControllerType.XBOX
		#elif name.contains("ps") or name.contains("playstation") or name.contains("play station") or name.contains("shock") or name.contains("sony"):
			#return GameControllerType.XBOX
		#elif name.contains("switch") or name.contains("nintendo"):
			#return GameControllerType.XBOX
		#elif name.contains("steam") or name.contains("valve"):
			#return GameControllerType.XBOX
	#
	#return GameControllerType.OTHER

func get_type_by_name(device_id := 0) -> GameControllerType:
	var name = Input.get_joy_name(device_id)
	if name.contains("xbox") or name.contains("series") or name.contains("microsoft"):
		return GameControllerType.XBOX
	elif name.contains("ps") or name.contains("playstation") or name.contains("play station") or name.contains("shock") or name.contains("sony"):
		return GameControllerType.PLAYSTATION
	elif name.contains("switch") or name.contains("nintendo"):
		return GameControllerType.SWITCH
	elif name.contains("steam") or name.contains("valve"):
		return GameControllerType.STEAM
	return GameControllerType.OTHER
