class_name FinishLine extends Node2D

signal crossed

func _on_area_2d_body_entered(body: Player) -> void:
	crossed.emit()
