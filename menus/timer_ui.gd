extends CanvasLayer

var actual_seconds_elapsed : float = 0
var time_multiplier : float = 1.0

@onready var current_time: Label = $MarginContainer/VBoxContainer/CurrentTime
@onready var personal_best: Label = $MarginContainer/VBoxContainer/PersonalBest
@onready var platinum_time: Label = $MarginContainer/VBoxContainer/PlatinumTime
@onready var gold_time: Label = $MarginContainer/VBoxContainer/GoldTime
@onready var silver_time: Label = $MarginContainer/VBoxContainer/SilverTime
@onready var bronze_time: Label = $MarginContainer/VBoxContainer/BronzeTime

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var dizziness = DizzyManager.get_dizziness()
	time_multiplier += dizziness 


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	actual_seconds_elapsed += delta
	
	# Format seconds into Minutes:Seconds (MM:SS)
	var seconds_displayed : int = actual_seconds_elapsed * time_multiplier
	var minutes_displayed : int = seconds_displayed % 60
	var millisconds_displayed : int = ((actual_seconds_elapsed * time_multiplier) - seconds_displayed) * 100
	
	
	# Update the UI label text using zero padding
	current_time.text = "%02d:%02d.%02d" % [minutes_displayed, seconds_displayed, millisconds_displayed]
