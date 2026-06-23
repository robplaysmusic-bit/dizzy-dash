class_name DizzinessUI extends MarginContainer

@onready var bar: ColorRect = $MarginContainer/Control/Bar

@export var dizzy_scale: float

func _ready() -> void:
	var dizziness: float = DizzyManager.get_dizziness()
	bar.scale = Vector2(dizziness / dizzy_scale, 1.0)

