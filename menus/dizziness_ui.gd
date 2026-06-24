class_name DizzinessUI extends MarginContainer

@onready var bar: ColorRect = $MarginContainer/Control/Bar

@export var live: bool # does this need to exist?

func _ready() -> void:
	update_dizziness()

func _process(_delta: float) -> void:
	if !live: return
	update_dizziness()

func update_dizziness() -> void:
	var dizziness: float = DizzyManager.get_dizziness()
	bar.scale = Vector2(dizziness / DizzyManager.MAX_EXTREMELY_DIZZY, 1.0)
