class_name SpinningMinigame
extends Node2D

const PI_1_2: float = PI / 2
const PI_3_2: float = PI * 3 / 2
const PI_2: float = PI * 2
const FUDGE: float = 0.01

@onready var line: Line2D = $Line2D

## how long you can wait without losing your current spin, a lower value means you have to spin faster for it to register
@export var pause_time_msec: int

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

func _process(_delta: float) -> void:
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
			push_warning("completed spin ", spins)
			for_goal = 0
			rev_goal = 0
	elif angle_in_range(direction, rev_goals[rev_goal], rev_goals[rev_goal + 1]):
		rev_goal += 1
		last_progress_msec = Time.get_ticks_msec()
		if rev_goal == 4:
			spins -= 1
			push_warning("completed spin ", spins)
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
