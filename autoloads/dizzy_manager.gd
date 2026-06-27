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
	var angle_range: float
	var min_angle: float
	var max_angle: float
	var angle_change_rate: float

	func _init(center: float, width: float, rate: float) -> void:
		self.angle_range = width
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

func get_dizziness() -> float:
	return _dizziness

func get_dizziness_tier() -> String:
	match _tier:
		Dizzy.NOT_DIZZY:
			return "Dizziness"
		Dizzy.SLIGHTLY:
			return "Hmm"
		Dizzy.SOMEWHAT:
			return "Oof"
		Dizzy.STANDARD:
			return "I'm dizzy"
		Dizzy.VERY:
			return "Oh man"
		Dizzy.EXTREMELY:
			return "Help!"
		_: #Dizzy.OH_NO
			return "Oh lawdy!"

# Intended to be called every physics processing frame to "correct" player inputs
func apply_dizziness(player_input : Vector2) -> Vector2:
	var effect := _info[_tier]
	# TODO: this cycles but with a discontinuity at 0. make it smooth
	var timer_progress := rotation_change_timer.time_left / rotation_change_timer.wait_time
	var rotation_angle := effect.min_angle + timer_progress * effect.angle_range

	return player_input.rotated(deg_to_rad(rotation_angle))

func format_time(time: float) -> String:
	var seconds := int(time)
	@warning_ignore("integer_division")
	var minutes := seconds / 60
	var subsec := int(fmod(time, 1.0) * 100.0)
	
	# Update the UI label text using zero padding
	return "%02d:%02d.%02d" % [minutes, seconds % 60, subsec % 100]
