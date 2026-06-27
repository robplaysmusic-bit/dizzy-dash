class_name ResultRow extends Control

@onready var time: Label = $HBoxContainer/TimeLabel
@onready var tier: Label = $HBoxContainer/TierLabel
@onready var hbox: HBoxContainer = $HBoxContainer

func set_text(description: String, t: float, color: Color) -> void:
	time.add_theme_color_override("font_color", color)
	tier.add_theme_color_override("font_color", color)
	time.text = DizzyManager.format_time(t)
	tier.text = description
