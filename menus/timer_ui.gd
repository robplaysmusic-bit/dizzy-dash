class_name TimerUI extends CanvasLayer

# Should be a constant but godot gets mad about compile time dependencies
# 1.0x time multiplier in the middile of the dizziness scale
var TIME_MULTIPLIER_NUMERATOR : float = DizzyManager.MAX_STANDARD_DIZZY

var start_time_msec: int = -1
var actual_seconds_elapsed : float = 0
var time_multiplier : float = 01.0
var stopped : bool = false

@onready var current_time: Label = $MarginContainer/VBoxContainer/CurrentTime
@onready var personal_best: Label = $MarginContainer/VBoxContainer/PersonalBest
@onready var platinum_time: Label = $MarginContainer/VBoxContainer/PlatinumTime
@onready var gold_time: Label = $MarginContainer/VBoxContainer/GoldTime
@onready var silver_time: Label = $MarginContainer/VBoxContainer/SilverTime
@onready var bronze_time: Label = $MarginContainer/VBoxContainer/BronzeTime

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	start_time_msec = Time.get_ticks_msec()
	var dizziness = DizzyManager.get_dizziness()
	if dizziness != 0:
		time_multiplier = TIME_MULTIPLIER_NUMERATOR / dizziness 
	else: #avoid divide by 0
		time_multiplier = TIME_MULTIPLIER_NUMERATOR

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if stopped: return
	
	actual_seconds_elapsed = (Time.get_ticks_msec() - start_time_msec) / 1000.0
	current_time.text = DizzyManager.format_time(actual_seconds_elapsed * time_multiplier)

func initialize_goal_times(plat : float, gold : float, silver : float, bronze : float) -> void:
	platinum_time.text = DizzyManager.format_time(plat)
	gold_time.text = DizzyManager.format_time(gold)
	silver_time.text = DizzyManager.format_time(silver)
	bronze_time.text = DizzyManager.format_time(bronze)

func halt_timer() -> float:
	stopped = true
	# TODO: Color current time based on medals. Some confetti or something.
	return (Time.get_ticks_msec() - start_time_msec) * time_multiplier / 1000.0
