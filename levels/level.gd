class_name Level extends Node2D

@export var platinum_time : String = "00:00.00"
@export var gold_time : String = "00:00.00"
@export var silver_time : String = "00:00.00"
@export var bronze_time : String = "00:00.00"
@export_file("*.tscn") var next_course : String

@onready var timer_ui: TimerUI = $TimerUI
@onready var finish_line: FinishLine = $FinishLine


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	finish_line.crossed.connect(_on_finish_line_crossed)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	timer_ui.initialize_goal_times(platinum_time, gold_time, silver_time, bronze_time)


func _on_finish_line_crossed() -> void:
	# TODO: Results screen, actually have them confirm before starting the next level (or retrying this one)
	timer_ui.halt_timer()
	LevelLoader.load_spin_game(next_course)
	queue_free()
