extends Node

@export_file("*.tscn") var next_course : String
@onready var animation_player: AnimationPlayer = $SceneTransitionCanvasLayer/AnimationPlayer

const SPIN_GAME : Resource = preload("res://levels/spin-test.tscn")



func set_next_course(next : String) -> void:
	next_course = next
	animation_player.play("fade_to_black")
	await animation_player.animation_finished
	get_tree().change_scene_to_packed(SPIN_GAME)
	animation_player.play("fade_from_black")
	
func load_next_course() -> void:
	animation_player.play("fade_to_black")
	await animation_player.animation_finished
	get_tree().change_scene_to_file(next_course)
	animation_player.play("fade_from_black")
