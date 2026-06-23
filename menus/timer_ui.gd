class_name TimerUI extends CanvasLayer

# Should be a constant but godot gets mad about compile time dependencies
# 1.0x time multiplier in the middile of the dizziness scale
var TIME_MULTIPLIER_NUMERATOR : float = DizzyManager.MAX_STANDARD_DIZZY

var actual_seconds_elapsed : float = 0
var time_multiplier : float = 01.0

@onready var current_time: Label = $MarginContainer/VBoxContainer/CurrentTime
@onready var personal_best: Label = $MarginContainer/VBoxContainer/PersonalBest
@onready var platinum_time: Label = $MarginContainer/VBoxContainer/PlatinumTime
@onready var gold_time: Label = $MarginContainer/VBoxContainer/GoldTime
@onready var silver_time: Label = $MarginContainer/VBoxContainer/SilverTime
@onready var bronze_time: Label = $MarginContainer/VBoxContainer/BronzeTime

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var dizziness = DizzyManager.get_dizziness()
	time_multiplier = TIME_MULTIPLIER_NUMERATOR / dizziness 

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	actual_seconds_elapsed += delta
	
	# Format seconds into Minutes:Seconds (MM:SS)
	var seconds_displayed : int = actual_seconds_elapsed * time_multiplier
	var minutes_displayed : int = seconds_displayed / 60
	var millisconds_displayed : int = ((actual_seconds_elapsed * time_multiplier) - seconds_displayed) * 100
	
	
	# Update the UI label text using zero padding
	current_time.text = "%02d:%02d.%02d" % [minutes_displayed, seconds_displayed, millisconds_displayed]

func initialize_goal_times(plat : String, gold : String, silver : String, bronze : String):
	platinum_time.text = plat
	gold_time.text = gold
	silver_time.text = silver
	bronze_time.text = bronze
