class_name Level extends Node2D

@export var platinum_time : float = 0
@export var gold_time : float = 0
@export var silver_time : float = 0
@export var bronze_time : float = 0
@export var level_num : int
@export_file("*.tscn") var next_course : String

@onready var player: Player = $Player
@onready var timer_ui: TimerUI = $TimerUI
@onready var finish_line: FinishLine = $FinishLine


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# never pause this node, since it manages pausing
	process_mode = Node.PROCESS_MODE_ALWAYS
	timer_ui.pause_ui.visible = false
	timer_ui.result_ui.visible = false
	if !RaceMusic.playing: # prevent restarting music on retry
		RaceMusic.play()
	finish_line.crossed.connect(_on_finish_line_crossed)
	TimeTracker.register_times(level_num, platinum_time, gold_time, silver_time, bronze_time)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	timer_ui.initialize_goal_times(platinum_time, gold_time, 1, bronze_time)
	if Input.is_action_pressed("jump"):
		if timer_ui.result_ui.visible:
			if next_course == ResourceUID.id_to_text(ResourceLoader.get_resource_uid("res://menus/final_results.tscn")):
				LevelLoader.load_final_results()
			else:
				LevelLoader.load_spin_game(next_course)
			queue_free.call_deferred()
	if Input.is_action_pressed("retry_spin"):
		if timer_ui.result_ui.visible or timer_ui.pause_ui.visible:
			LevelLoader.load_spin_game(scene_file_path)
			queue_free.call_deferred()
	elif Input.is_action_pressed("back"):
		if timer_ui.result_ui.visible or timer_ui.pause_ui.visible:
			get_tree().paused = false
			LevelLoader.load_next_course()
			queue_free.call_deferred()

	if Input.is_action_just_pressed("menu"):
		if !timer_ui.result_ui.visible:
			var pause := !timer_ui.pause_ui.visible
			timer_ui.set_pause(pause)
			get_tree().paused = pause

func _on_finish_line_crossed() -> void:
	player.active = false
	var result := timer_ui.halt_timer()
	TimeTracker.record_time(level_num, result)
	timer_ui.result_ui.set_score(platinum_time, gold_time, silver_time, bronze_time, result, TimeTracker.get_best_time(level_num))
	timer_ui.result_ui.visible = true
