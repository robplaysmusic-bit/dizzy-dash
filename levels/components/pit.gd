class_name Pit extends Node2D

func _on_pit_entered(_body: Node2D) -> void:
	get_tree().call_group("player", "die")
