class_name DizzinessUI extends MarginContainer

@onready var bar: ColorRect = $MarginContainer/Control/Bar

@export var dizzy_scale: float
@export var live: bool
@export var tween_speed: float

func _ready() -> void:
	update_dizziness()

func _process(_delta: float) -> void:
	if !live: return
	update_dizziness()

func update_dizziness() -> void:
	var dizziness: float = DizzyManager.get_dizziness()
	bar.scale = Vector2(dizziness / dizzy_scale, 1.0)
