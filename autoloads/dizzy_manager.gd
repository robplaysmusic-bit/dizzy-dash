extends Node

enum Dizzy { 
	NOT_DIZZY, # no effect
	SLIGHTLY, # controls inverted (180 degrees)
	SOMEWHAT, # controls are +/- 30-60 degrees
	STANDARD, # controls are +/- 60-120 degrees
	VERY, # controls slowly fluctuate +/- 45-90 degrees
	EXTREMELY, # controls quickly fluctuate +/- 60-120 degrees
	OH_NO  # controls 
}
const MAX_NOT_DIZZY_VALUE : int = 0
const MAX_SLIGHTLY_DIZZY_VALUE : int = 50
const MAX_SOMEWHAT_DIZZY_VALUE : int = 100
const MAX_STANDARD_DIZZY_VALUE : int = 200
const MAX_VERY_DIZZY_VALUE : int = 300
const MAX_EXTREMELY_DIZZY_VALUE : int = 500
const MAX_OH_NO_DIZZY_VALUE : int = 1e10

const MIN_ROTATION_INDEX : int = 0
const MAX_ROTATION_INDEX : int = 1
const ROTATION_CHANGE_INDEX : int = 2
# tier : [min angle, max angle, angle change rate]
const _info : Dictionary[Dizzy, Array] = {
	Dizzy.NOT_DIZZY : 		[0,		0,		0],
	Dizzy.SLIGHTLY : 		[175, 	185,	0], # centered around 180
	Dizzy.SOMEWHAT : 		[30, 	60,		0], # centered around 45
	Dizzy.STANDARD : 		[60, 	120,	0], # centered around 90
	Dizzy.VERY : 			[60, 	120,	1], 
	Dizzy.EXTREMELY: 		[60, 	120,	0.5],
	Dizzy.OH_NO :			[30,	150,	0.01]
}

var _tier : Dizzy = Dizzy.NOT_DIZZY
# Value determined by player in spin mini-game - no upper bound
# basic tiers of player impact:
var _dizziness : int: 
	set(value):
		_dizziness = value
		if _dizziness == MAX_NOT_DIZZY_VALUE : 
			_tier = Dizzy.NOT_DIZZY
		elif _dizziness <= MAX_SLIGHTLY_DIZZY_VALUE :
			_tier = Dizzy.SLIGHTLY
		elif _dizziness <= MAX_SOMEWHAT_DIZZY_VALUE :
			_tier = Dizzy.SOMEWHAT
		elif _dizziness <= MAX_STANDARD_DIZZY_VALUE :
			_tier = Dizzy.STANDARD
		elif _dizziness <= MAX_VERY_DIZZY_VALUE :
			_tier = Dizzy.VERY
		elif _dizziness <= MAX_EXTREMELY_DIZZY_VALUE :
			_tier = Dizzy.EXTREMELY
		elif _dizziness <= MAX_OH_NO_DIZZY_VALUE :
			_tier = Dizzy.OH_NO
		else:
			push_warning("Unhandled / negative dizziness value")

var rotation_increasing : bool = true
@onready var rotation_change_timer: Timer = $RotationChangeTimer


func set_dizziness(value : float):
	_dizziness = value

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
	print("dizzly input: ", str(dizzy_input))
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
