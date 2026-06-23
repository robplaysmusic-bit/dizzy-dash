extends Node

enum Dizzy { NOT_DIZZY, SLIGHTLY, SOMEWHAT, STANDARD, VERY, EXTREMELY, OH_NO }
const MAX_NOT_DIZZY : int = 4
const MAX_SLIGHTLY_DIZZY : int = 8
const MAX_SOMEWHAT_DIZZY : int = 12
const MAX_STANDARD_DIZZY : int = 16
const MAX_VERY_DIZZY : int = 20
const MAX_EXTREMELY_DIZZY : int = 25
const MAX_OH_NO_DIZZY : int = 5000

const MIN_ROTATION_INDEX : int = 0
const MAX_ROTATION_INDEX : int = 1
const ROTATION_CHANGE_INDEX : int = 2
# tier : [min angle, max angle, angle change rate]
const _info : Dictionary[Dizzy, Array] = {
	Dizzy.NOT_DIZZY : 		[0,		0,		0.0],
	Dizzy.SLIGHTLY : 		[178, 	182,	0.0], # centered around 180
	Dizzy.SOMEWHAT : 		[28, 	32,		0.0], # centered around 30
	Dizzy.STANDARD : 		[43, 	47,		0.0], # centered around 45
	Dizzy.VERY : 			[58, 	62,		1.0], # centered around 60
	Dizzy.EXTREMELY: 		[85, 	95,		0.5], # centered around 90
	Dizzy.OH_NO :			[80,	100,	0.1]  # centered around 90
}

var _tier : Dizzy = Dizzy.NOT_DIZZY
# Value determined by player in spin mini-game - no upper bound
# basic tiers of player impact:
var _dizziness : int = MAX_STANDARD_DIZZY: 
	set(value):
		_dizziness = value
		if _dizziness <= MAX_NOT_DIZZY : 
			_tier = Dizzy.NOT_DIZZY
		elif _dizziness <= MAX_SLIGHTLY_DIZZY :
			_tier = Dizzy.SLIGHTLY
		elif _dizziness <= MAX_SOMEWHAT_DIZZY :
			_tier = Dizzy.SOMEWHAT
		elif _dizziness <= MAX_STANDARD_DIZZY :
			_tier = Dizzy.STANDARD
		elif _dizziness <= MAX_VERY_DIZZY :
			_tier = Dizzy.VERY
		elif _dizziness <= MAX_EXTREMELY_DIZZY :
			_tier = Dizzy.EXTREMELY
		elif _dizziness <= MAX_OH_NO_DIZZY :
			_tier = Dizzy.OH_NO
		else:
			push_warning("Unhandled / negative dizziness value")

var rotation_increasing : bool = true
@onready var rotation_change_timer: Timer = $RotationChangeTimer

# Dizziness should be set before loading the next level
func set_dizziness(value : int):
	_dizziness = value
	# if we were dizzier in a previous round than this one, we want to avoid
	# unintentionally changing rotation.
	rotation_change_timer.stop()

func get_dizziness() -> float:
	return _dizziness


# Intended to be called every physics processing frame to "correct" player inputs
func apply_dizziness(player_input : Vector2) -> Vector2:
	var dizzy_input : Vector2 = Vector2.ZERO
	var rotation_angle : int = 0
	
	var rotation_range : int = _info[_tier][MAX_ROTATION_INDEX] - _info[_tier][MIN_ROTATION_INDEX]
	if _tier != Dizzy.NOT_DIZZY: # avoid modulo by zero
		rotation_angle = _info[_tier][MIN_ROTATION_INDEX] + (_dizziness % rotation_range)
	
	if _info[_tier][ROTATION_CHANGE_INDEX] > 0 and rotation_change_timer.is_stopped():
		rotation_change_timer.start(_info[_tier][ROTATION_CHANGE_INDEX])
	
	dizzy_input = player_input.rotated(deg_to_rad(rotation_angle))
	return dizzy_input


func _on_rotation_change_timer_timeout() -> void:
	var previous_tier = _tier
	if rotation_increasing:
		_dizziness += 1
	else:
		_dizziness -= 1
	
	# we hit a boundary, change directions
	if _tier != previous_tier:
		rotation_increasing = !rotation_increasing
		if rotation_increasing:
			_dizziness += 1
		else:
			_dizziness -= 1
