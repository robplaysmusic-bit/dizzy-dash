class_name Level extends Node2D

@export var platinum_time : String = "00:00.00"
@export var gold_time : String = "00:00.00"
@export var silver_time : String = "00:00.00"
@export var bronze_time : String = "00:00.00"

@onready var timer_ui: TimerUI = $TimerUI


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	timer_ui.initialize_goal_times(platinum_time, gold_time, silver_time, bronze_time)
