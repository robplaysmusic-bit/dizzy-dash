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
	## the effect generally rotates input by this much
	var angle_center: float
	## the effect rotates + or - this much
	var angle_half_width: float
	## how long it takes input rotation to oscillate
	var angle_change_duration: float

	func _init(center: float, half_width: float, duration: float) -> void:
		self.angle_center = center
		self.angle_half_width = half_width
		self.angle_change_duration = duration


var _info : Dictionary[Dizzy, DizzyEffect] = {
	Dizzy.NOT_DIZZY: DizzyEffect.new(  0,  0, 6.0),
	Dizzy.SLIGHTLY : DizzyEffect.new(180,  2, 6.0),
	Dizzy.SOMEWHAT : DizzyEffect.new( 45,  2, 6.0),
	Dizzy.STANDARD : DizzyEffect.new( 60,  4, 6.0),
	Dizzy.VERY     : DizzyEffect.new( 75,  6, 4.0),
	Dizzy.EXTREMELY: DizzyEffect.new( 90,  8, 2.0),
	Dizzy.OH_NO    : DizzyEffect.new( 90, 10, 1.0)
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
	# restart timer to change its wait time
	rotation_change_timer.start(_info[_tier].angle_change_duration)

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
	var time_proportion_remaining := 0.0
	if rotation_change_timer.wait_time > 0:
		# loops 1 smoothly down to 0 (then instantly back to 1)
		time_proportion_remaining = rotation_change_timer.time_left / rotation_change_timer.wait_time
	# loops smoothly 0 to -1 to 0 to 1 to 0
	var variance := sin(time_proportion_remaining * PI * 2)
	var rotation_angle := effect.angle_center + variance * effect.angle_half_width

	return player_input.rotated(deg_to_rad(rotation_angle))

func format_time(time: float) -> String:
	var seconds := int(time)
	@warning_ignore("integer_division")
	var minutes := seconds / 60
	var subsec := int(fmod(time, 1.0) * 100.0)
	
	# Update the UI label text using zero padding
	return "%02d:%02d.%02d" % [minutes, seconds % 60, subsec % 100]

## works around a bug in Input.get_vector where switching between buttons and joystick results in buttons not returning axis-aligned vectors
func input_vector_fixed() -> Array:
	var used_joystick := true
	var input := Vector2(Input.get_joy_axis(0, JOY_AXIS_LEFT_X), Input.get_joy_axis(0, JOY_AXIS_LEFT_Y))
	# dead zone 0.2
	if input.length_squared() <= 0.04:
		used_joystick = false
		input = Vector2.ZERO
	if Input.is_action_pressed("up"):
		input += Vector2(0, -1)
	if Input.is_action_pressed("down"):
		input += Vector2(0, 1)
	if Input.is_action_pressed("left"):
		input += Vector2(-1, 0)
	if Input.is_action_pressed("right"):
		input += Vector2(1, 0)
	return [input.normalized(), used_joystick]
