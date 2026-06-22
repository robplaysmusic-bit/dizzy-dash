extends Node


var dizziness : float = 90.0

const DIZZINESS_DECAY_RATE = .0005 # degrees per frame

func apply_dizziness(player_velocity : Vector2) -> Vector2:
	var dizzy_velocity : Vector2 = Vector2.ZERO
	dizzy_velocity = player_velocity.rotated(deg_to_rad(dizziness))
	return dizzy_velocity
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	#dizziness += .01
	pass
