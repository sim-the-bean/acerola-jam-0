extends Area3D

signal player_entered(player: Player)
signal player_exited(player: Player)

func _on_body_entered(body):
	if body is Player:
		player_entered.emit(body)

func _on_body_exited(body):
	if body is Player:
		player_exited.emit(body)
