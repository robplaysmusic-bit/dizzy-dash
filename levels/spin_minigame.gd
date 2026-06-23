class_name SpinningMinigame
extends Node2D

const PI_1_2: float = PI / 2
const PI_3_2: float = PI * 3 / 2
const PI_2: float = PI * 2
const FUDGE: float = 0.01

@onready var line: Line2D = $Line2D
@onready var time_remaining: Label = $CanvasLayer/MarginContainer/TimeRemaining
@onready var spin_time: Timer = $SpinTime
@onready var warning_timer: Timer = $WarningTimer

## how long you can wait without losing your current spin, a lower value means you have to spin faster for it to register
@export var pause_time_msec: int
# time, in seconds, that the player has to spin their spins
@export var mini_game_time : float
@export var warning_time : float

var total_game_time_msec: int
var mini_game_start_msec: int

# number of completed spins (negative if spinning counter clockwise)
var spins: int = 0
# next angle range index needed to continue spin in either direction (<0 if unset)
var for_goal: int = -1
var rev_goal: int = -1
# angle ranges needed to complete spin
var for_goals: Array[float]
var rev_goals: Array[float]
# where you started your spin (if goal is >= 0)
var start_direction: float = 10
# time in msec that you last progressed your spin
var last_progress_msec: int = 0
# set when the game is over - tells us to stop counting spins
var disabled : bool = false

func _ready() -> void:
	DizzyManager.set_dizziness(0)
	_update_timer_label()
	total_game_time_msec = int(mini_game_time * 1000)
	mini_game_start_msec = Time.get_ticks_msec()
	spin_time.start(mini_game_time)
	warning_timer.start(warning_time)

func _process(_delta: float) -> void:
	if disabled : return
	
	mini_game_time = (total_game_time_msec - (Time.get_ticks_msec() - mini_game_start_msec)) / 1000.0
	_update_timer_label()
	
	var input := Input.get_vector("left", "right", "up", "down")
	if input == Vector2.ZERO:
		return

	var direction := input.angle()
	line.global_rotation = direction
	# if no goal, set it
	if for_goal < 0:
		set_spin_goals(direction)
		return

	if Time.get_ticks_msec() - last_progress_msec > pause_time_msec:
		# spin timed out, restart
		for_goal = -1
		rev_goal = -1
	elif angle_in_range(direction, for_goals[for_goal], for_goals[for_goal + 1]):
		for_goal += 1
		last_progress_msec = Time.get_ticks_msec()
		if for_goal == 4:
			spins += 1
			DizzyManager.set_dizziness(abs(spins))
			for_goal = 0
			rev_goal = 0
	elif angle_in_range(direction, rev_goals[rev_goal], rev_goals[rev_goal + 1]):
		rev_goal += 1
		last_progress_msec = Time.get_ticks_msec()
		if rev_goal == 4:
			spins -= 1
			DizzyManager.set_dizziness(abs(spins))
			rev_goal = 0
			for_goal = 0

func set_spin_goals(direction: float) -> void:
	for_goal = 0
	rev_goal = 0
	for_goals = [direction, direction + PI_1_2, direction + PI, direction + PI_3_2, direction + PI_2]
	rev_goals = [direction, direction - PI_1_2, direction - PI, direction - PI_3_2, direction - PI_2]
	start_direction = direction
	last_progress_msec = Time.get_ticks_msec()

# is angle in the range (start, end], where angle is in [-PI, PI]
func angle_in_range(angle: float, start: float, end: float) -> bool:
	assert(start != end, "range must not be empty")
	if end > start:
		while angle < start:
			angle += PI_2
		return angle > start && angle <= end + FUDGE
	else: # end < start
		while angle > start:
			angle -= PI_2
		return angle < start && angle >= end - FUDGE

func _update_timer_label() -> void:
	var seconds_remaining = int(mini_game_time)
	var ms_remaining = (mini_game_time - seconds_remaining) * 100
	time_remaining.text = "%02d.%02d" % [seconds_remaining, ms_remaining]

func _on_spin_time_timeout() -> void:
	disabled = true
	time_remaining.text = "00.00" # account for timing variation
	DizzyManager.set_dizziness(abs(spins))
	LevelLoader.load_next_course()
	queue_free()

func _on_warning_timer_timeout() -> void:
	var tween_color : Tween = get_tree().create_tween()
	tween_color.tween_method(
		func(color:Color) -> void:
			time_remaining.add_theme_color_override("font_color", color),
			Color.WHITE, Color.RED,
			mini_game_time
	)
