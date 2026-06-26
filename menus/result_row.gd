class_name ResultRow extends Control

@onready var left: Label = $HBoxContainer/TimeLabel
@onready var right: Label = $HBoxContainer/TierLabel
@onready var hbox: HBoxContainer = $HBoxContainer

func set_text(description: String, time: float, color: Color) -> void:
	left.add_theme_color_override("font_color", color)
	right.add_theme_color_override("font_color", color)
	left.text = DizzyManager.format_time(time)
	right.text = description
