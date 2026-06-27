class_name TimerUI extends CanvasLayer

# Should be a constant but godot gets mad about compile time dependencies
# 1.0x time multiplier in the middile of the dizziness scale
var TIME_MULTIPLIER_NUMERATOR : float = DizzyManager.MAX_STANDARD_DIZZY

var accumulated_msec: int = 0
var start_time_msec: int = -1
var actual_seconds_elapsed : float = 0
var time_multiplier : float = 01.0
var stopped : bool = false

@onready var current_time: Label = $MarginContainer/VBoxContainer/CurrentTime
@onready var platinum_time: Label = $MarginContainer/VBoxContainer/PlatinumTime
@onready var gold_time: Label = $MarginContainer/VBoxContainer/GoldTime
@onready var silver_time: Label = $MarginContainer/VBoxContainer/SilverTime
@onready var bronze_time: Label = $MarginContainer/VBoxContainer/BronzeTime
@onready var result_ui: ResultUI = $ResultUI
@onready var pause_ui: Control = $PauseUI
@onready var dizzy_debug: Label = $DizzyDebug
@onready var input_debug: Label = $InputDebug

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	start_time_msec = Time.get_ticks_msec()
	var dizziness := DizzyManager.get_dizziness()
	if dizziness != 0:
		time_multiplier = TIME_MULTIPLIER_NUMERATOR / dizziness 
	else: #avoid divide by 0
		time_multiplier = TIME_MULTIPLIER_NUMERATOR
	
func set_pause(pause: bool) -> void:
	if pause:
		accumulated_msec += Time.get_ticks_msec() - start_time_msec
	else:
		start_time_msec = Time.get_ticks_msec()
	pause_ui.visible = pause

func elapsed_msec() -> int:
	if stopped:
		return accumulated_msec
	return Time.get_ticks_msec() - start_time_msec + accumulated_msec

func elapsed_time() -> float:
	return elapsed_msec() * time_multiplier / 1000.0

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	var input: Vector2 = DizzyManager.input_vector_fixed()[0]
	if input == Vector2.ZERO:
		input_debug.text = ""
		dizzy_debug.text = ""
	else:
		input_debug.text = "%d" % int(rad_to_deg(input.angle()))
		var output: Vector2 = DizzyManager.apply_dizziness(input)
		dizzy_debug.text = "%d" % int(rad_to_deg(output.angle()))
	if stopped or pause_ui.visible: return
	
	actual_seconds_elapsed = elapsed_time()
	current_time.text = DizzyManager.format_time(actual_seconds_elapsed)

func initialize_goal_times(plat : float, gold : float, silver : float, bronze : float) -> void:
	platinum_time.text = DizzyManager.format_time(plat)
	gold_time.text = DizzyManager.format_time(gold)
	silver_time.text = DizzyManager.format_time(silver)
	bronze_time.text = DizzyManager.format_time(bronze)

func halt_timer() -> float:
	accumulated_msec = elapsed_msec()
	stopped = true
	# TODO: Color current time based on medals. Some confetti or something.
	return elapsed_time()
