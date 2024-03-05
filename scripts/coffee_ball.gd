@tool
extends Glitched

func _ready():
	if not Engine.is_editor_hint():
		%Collider.disabled = true

func _on_kill_box_body_entered(body):
	if not body is CoffeeMug and body != self:
		super(body)

func _on_kill_box_body_exited(body):
	if body is CoffeeMug:
		%Collider.set_deferred("disabled", false)
