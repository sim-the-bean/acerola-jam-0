extends Node3D

var enabled := true:
	set(value):
		if enabled != value:
			enabled = value
			visible = enabled
			%Camera.set_priority(30 if enabled else 0)
			if enabled:
				%Newspaper.first_page()
			else:
				%Newspaper.disable_all()
