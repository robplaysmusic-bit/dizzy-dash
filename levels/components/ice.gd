extends Node2D

func _on_area_2d_body_entered(body: Player) -> void:
	get_tree().call_group("player", "enter_ice")


func _on_area_2d_body_exited(body: Player) -> void:
	get_tree().call_group("player", "exit_ice")
