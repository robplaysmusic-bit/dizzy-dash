class_name ResultRow extends Control

@onready var left: Label = $Label2
@onready var right: Label = $Label

func set_text(description: String, time: float, color: Color) -> void:
	left.add_theme_color_override("font_color", color)
	right.add_theme_color_override("font_color", color)
	left.text = description
	right.text = DizzyManager.format_time(time)
