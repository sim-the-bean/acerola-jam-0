extends Node
class_name CheckpointComponent

@onready var initial_transform: Transform3D = get_parent().transform

func _ready():
	if get_parent().has_node("KillComponent"):
		get_parent().get_node("KillComponent").free_on_killed = false
		get_parent().get_node("KillComponent").disable_on_killed = true

func reset():
	get_parent().transform = initial_transform
	if get_parent() is RigidBody3D:
		get_parent().linear_velocity = Vector3.ZERO
		get_parent().angular_velocity = Vector3.ZERO
		get_parent().sleeping = true
	if get_parent().has_node("KillComponent"):
		get_parent().visible = true
		get_parent().process_mode = Node.PROCESS_MODE_INHERIT
