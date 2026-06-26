class_name DizzinessUI extends MarginContainer

@onready var bar: ColorRect = $MarginContainer/Control/Bar
@onready var label: Label = $Label

func _ready() -> void:
	update_dizziness()

func _process(_delta: float) -> void:
	update_dizziness()

func update_dizziness() -> void:
	var dizziness: float = DizzyManager.get_dizziness()
	bar.scale = Vector2(dizziness / DizzyManager.MAX_EXTREMELY_DIZZY, 1.0)
	label.text = DizzyManager.get_dizziness_tier()
