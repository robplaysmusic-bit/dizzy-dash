class_name FinalResultsUI extends CanvasLayer

const COURSE_1 : String = "res://levels/level-1.tscn"
const COURSE_2 : String = "res://levels/level-2.tscn"
const COURSE_3 : String = "res://levels/level-3.tscn"


@onready var course_1_results: ResultRow = $Results/VBoxContainer/MarginContainer2/VBoxContainer/Course1Results
@onready var course_2_results: ResultRow = $Results/VBoxContainer/MarginContainer2/VBoxContainer/Course2Results
@onready var course_3_results: ResultRow = $Results/VBoxContainer/MarginContainer2/VBoxContainer/Course3Results

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var course_1_time = TimeTracker.get_best_time(1)
	var course_1_color = TimeTracker.get_time_color(1)
	course_1_results.set_text("Course 1", course_1_time, course_1_color)

	var course_2_time = TimeTracker.get_best_time(2)
	var course_2_color = TimeTracker.get_time_color(2)
	course_2_results.set_text("Course 2", course_2_time, course_2_color)
	
	var course_3_time = TimeTracker.get_best_time(3)
	var course_3_color = TimeTracker.get_time_color(3)
	course_3_results.set_text("Course 3", course_3_time, course_3_color)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_released("jump"):
		LevelLoader.load_spin_game(COURSE_1)
	elif Input.is_action_just_released("back"):
		LevelLoader.load_spin_game(COURSE_2)
	elif Input.is_action_just_released("retry_spin"):
		LevelLoader.load_spin_game(COURSE_3)
