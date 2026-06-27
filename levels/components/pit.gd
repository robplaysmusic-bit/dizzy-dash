class_name Pit extends Node2D

func _on_pit_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		get_tree().call_group("player", "die")
