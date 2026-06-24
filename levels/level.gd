class_name Level extends Node2D

@export var platinum_time : float = 0
@export var gold_time : float = 0
@export var silver_time : float = 0
@export var bronze_time : float = 0
@export_file("*.tscn") var next_course : String

@onready var player: Player = $Player
@onready var timer_ui: TimerUI = $TimerUI
@onready var finish_line: FinishLine = $FinishLine
@onready var result_ui: ResultUI = $TimerUI/ResultUI


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	result_ui.visible = false
	finish_line.crossed.connect(_on_finish_line_crossed)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	timer_ui.initialize_goal_times(platinum_time, gold_time, silver_time, bronze_time)


func _on_finish_line_crossed() -> void:
	# TODO: Results screen, actually have them confirm before starting the next level (or retrying this one)
	player.active = false
	var result := timer_ui.halt_timer()
	result_ui.set_score(platinum_time, gold_time, silver_time, bronze_time, result, 20.0)
	result_ui.visible = true
	#LevelLoader.load_spin_game(next_course)
	#queue_free()
