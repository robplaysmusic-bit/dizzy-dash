extends Node

@export_file("*.tscn") var next_course : String
@onready var animation_player: AnimationPlayer = $SceneTransitionCanvasLayer/AnimationPlayer

const SPIN_GAME : Resource = preload("res://levels/spin-test.tscn")
const FINAL_RESULTS : Resource = preload("res://menus/final_results.tscn")

func load_spin_game(next : String) -> void:
	# unpause so we don't get trapped in await animation hell
	if get_tree().paused : get_tree().paused = false
	next_course = next
	animation_player.play("fade_to_black")
	await animation_player.animation_finished
	get_tree().change_scene_to_packed(SPIN_GAME)
	animation_player.play("fade_from_black")
	
func load_next_course() -> void:
	# unpause so we don't get trapped in await animation hell
	if get_tree().paused : get_tree().paused = false
	animation_player.play("fade_to_black")
	await animation_player.animation_finished
	get_tree().change_scene_to_file(next_course)
	animation_player.play("fade_from_black")

func load_final_results() -> void:
	# unpause so we don't get trapped in await animation hell
	if get_tree().paused : get_tree().paused = false
	animation_player.play("fade_to_black")
	await animation_player.animation_finished
	get_tree().change_scene_to_packed(FINAL_RESULTS)
	animation_player.play("fade_from_black")
