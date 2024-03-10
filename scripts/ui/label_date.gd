@tool
extends Label

var months := [
	"January",
	"February",
	"March",
	"April",
	"May",
	"June",
	"July",
	"August",
	"September",
	"October",
	"November",
	"December",
]

func _ready():
	reset_label()

func reset_label():
	var time := Time.get_datetime_dict_from_system()
	text = "{0} {1}, {2}".format([months[time.month - 1], time.day, time.year - 70])
