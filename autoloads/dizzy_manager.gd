extends Node

enum Dizzy { NOT_DIZZY, SLIGHTLY, SOMEWHAT, STANDARD, VERY, EXTREMELY, OH_NO }
const MAX_NOT_DIZZY : int = 4
const MAX_SLIGHTLY_DIZZY : int = 8
const MAX_SOMEWHAT_DIZZY : int = 12
const MAX_STANDARD_DIZZY : int = 16
const MAX_VERY_DIZZY : int = 20
const MAX_EXTREMELY_DIZZY : int = 25
const MAX_OH_NO_DIZZY : int = 5000

class DizzyEffect:
	var min_angle: float
	var max_angle: float
	var angle_change_rate: float

	func _init(center: float, width: float, rate: float) -> void:
		self.min_angle = center - width
		self.max_angle = center + width
		self.angle_change_rate = rate


var _info : Dictionary[Dizzy, DizzyEffect] = {
	Dizzy.NOT_DIZZY: DizzyEffect.new(  0,  0, 0.0),
	Dizzy.SLIGHTLY : DizzyEffect.new(180,  2, 0.0),
	Dizzy.SOMEWHAT : DizzyEffect.new( 45,  2, 0.0),
	Dizzy.STANDARD : DizzyEffect.new( 45, 13, 0.0),
	Dizzy.VERY     : DizzyEffect.new( 75, 10, 1.0),
	Dizzy.EXTREMELY: DizzyEffect.new( 90,  5, 0.5),
	Dizzy.OH_NO    : DizzyEffect.new( 90, 10, 0.1)
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
func set_dizziness(value : int) -> void:
	_dizziness = value
	# if we were dizzier in a previous round than this one, we want to avoid
	# unintentionally changing rotation.
	rotation_change_timer.stop()

func get_dizziness() -> float:
	return _dizziness


# Intended to be called every physics processing frame to "correct" player inputs
func apply_dizziness(player_input : Vector2) -> Vector2:
	var dizzy_input : Vector2 = Vector2.ZERO
	var rotation_angle := 0.0
	
	var rotation_range := _info[_tier].max_angle - _info[_tier].min_angle
	if _tier != Dizzy.NOT_DIZZY: # avoid modulo by zero
		rotation_angle = _info[_tier].min_angle + (fmod(_dizziness, rotation_range))
	
	if _info[_tier].angle_change_rate > 0 and rotation_change_timer.is_stopped():
		rotation_change_timer.start(_info[_tier].angle_change_rate)
	
	dizzy_input = player_input.rotated(deg_to_rad(rotation_angle))
	return dizzy_input


func _on_rotation_change_timer_timeout() -> void:
	var previous_tier := _tier
	if rotation_increasing:
		_dizziness += 1
	else:
		_dizziness -= 1
	
	# we hit a boundary, change directions
	if _tier != previous_tier or _dizziness == _info[Dizzy.OH_NO].max_angle:
		rotation_increasing = !rotation_increasing
		if rotation_increasing:
			_dizziness += 1
		else:
			_dizziness -= 1

func format_time(time: float) -> String:
	var seconds := int(time)
	@warning_ignore("integer_division")
	var minutes := seconds / 60
	var subsec := int(fmod(time, 1.0) * 100.0)
	
	# Update the UI label text using zero padding
	return "%02d:%02d.%02d" % [minutes, seconds % 60, subsec % 100]
