class_name Player extends RigidBody2D

const MAX_WALK_SPEED : float = 200.0
const WALK_ACCEL : float = 1000.0
const WALK_DEACCEL : float = 1000.0

const JUMP_TIME : float = 0.5
const RESPAWN_TIME : float = 1.0
const RESPAWN_DISTANCE : float = 100.0

const ICY_DAMP : float = 0.5
const NORMAL_DAMP : float = 5.0
const SAND_DAMP : float = 10.0

var active := true
var dying : bool = false
var dead : bool = false
var death_position : Vector2
var death_velocity : Vector2

var on_ice : bool = false
var previously_on_ice : bool = false

var last_direction : Vector2 = Vector2.DOWN

@export var move_scale: float

@onready var jump_timer: Timer = $JumpTimer
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var respawn_timer: Timer = $RespawnTimer

func _integrate_forces(state: PhysicsDirectBodyState2D) -> void:
	if dying or dead: 
		if dying:
			death_velocity = state.get_linear_velocity()
			await get_tree().create_timer(0.1).timeout
			state.set_linear_velocity(Vector2.ZERO)
			dying = false
			dead = true
		return
	var velocity := state.get_linear_velocity()
	
	var raw_input := Vector2.ZERO
	# read player inputs and apply dizziness
	if active:
		raw_input = DizzyManager.input_vector_fixed()
	var dizzy_input := DizzyManager.apply_dizziness(raw_input)

	if Input.is_action_just_pressed("jump") and jump_timer.is_stopped():
		_handle_jump()

	state.apply_force(dizzy_input * move_scale)

	_handle_icy_terrain()
	_handle_animations(velocity)

func is_jumping() -> bool:
	return !jump_timer.is_stopped()

func die() -> void:
	dying = true
	death_position = global_position
	respawn_timer.start(RESPAWN_TIME)
	var death_tween : Tween = get_tree().create_tween()
	death_tween.tween_property(sprite, "scale", Vector2(0, 0), RESPAWN_TIME/2)
	# TODO: perhaps some poof particle effect on await tween finished
	pass

func enter_ice() -> void:
	on_ice = true

func exit_ice() -> void:
	on_ice = false


func _handle_animations(velocity : Vector2) -> void:
	var x_abs : float = abs(velocity.x)
	var y_abs : float = abs(velocity.y)
	
	if x_abs < 10 and y_abs < 10:
		match last_direction:
			Vector2.LEFT:
				sprite.play("idle_left")
			Vector2.RIGHT:
				sprite.play("idle_right")
			Vector2.UP:
				sprite.play("idle_up")
			Vector2.DOWN:
				sprite.play("idle_down")
		return
			
	
	if x_abs > y_abs:
		if velocity.x > 0:
			sprite.play("walk_right")
			last_direction = Vector2.RIGHT
		else:
			sprite.play("walk_left")
			last_direction = Vector2.LEFT
	else:
		if velocity.y > 0: 
			sprite.play("walk_down")
			last_direction = Vector2.DOWN
		else: 
			sprite.play("walk_up")
			last_direction = Vector2.UP

func _handle_icy_terrain() -> void:
	if on_ice != previously_on_ice:
		if on_ice:
			linear_damp_mode = RigidBody2D.DAMP_MODE_REPLACE
			linear_damp = ICY_DAMP
		else:
			linear_damp_mode = RigidBody2D.DAMP_MODE_REPLACE
			linear_damp = NORMAL_DAMP
	previously_on_ice = on_ice


func _handle_jump() -> void:
	# bit 1 is for jump collisions
	collision_layer = 0b10 
	collision_mask = 0b10
	jump_timer.start(JUMP_TIME)

	# TODO: maybe play an actual jump animation
	var jump_tween : Tween = get_tree().create_tween()
	jump_tween.tween_property(sprite, "scale", Vector2(1.5, 1.5), JUMP_TIME/2)
	await jump_tween.finished
	var fall_tween : Tween = get_tree().create_tween()
	fall_tween.tween_property(sprite, "scale", Vector2(1.0, 1.0), JUMP_TIME/2)

func _on_jump_timer_timeout() -> void:
	# bit 0 is for grounded collisions
	collision_layer = 0b1
	collision_mask = 0b1


func _on_respawn_timer_timeout() -> void:
	# Respawn the player opposite the direction they were moving when they died
	if death_velocity != Vector2.ZERO:
		var direction := death_velocity.normalized()
		self.global_position = self.global_position - (direction * RESPAWN_DISTANCE)
	else:
		push_warning("Died with no velocity ... not sure how to handle it. Let's hope it doesn't happen for now.")
	# have the player reappear
	# TODO: some animation / particle effect
	sprite.scale = Vector2(1,1)
	dying = false
	dead = false
