class_name Player extends RigidBody2D

const MAX_WALK_SPEED : float = 200.0
const WALK_ACCEL : float = 1000.0
const WALK_DEACCEL : float = 1000.0

# not convinced this should actually be a thing
const MAX_RUN_SPEED : float = 400.0
const RUN_ACCEL : float = 500.0

var active := true

func _integrate_forces(state: PhysicsDirectBodyState2D) -> void:
	var velocity := state.get_linear_velocity()
	var step := state.get_step()
	
	var raw_input := Vector2.ZERO
	# read player inputs and apply dizziness
	if active:
		raw_input = Input.get_vector("left", "right", "up", "down")
	var dizzy_input = DizzyManager.apply_dizziness(raw_input)

	# left / right movement
	if dizzy_input.x < 0:
		if velocity.x > -MAX_WALK_SPEED:
			velocity.x -= WALK_ACCEL * step
	elif dizzy_input.x > 0:
		if velocity.x < MAX_WALK_SPEED:
			velocity.x += WALK_ACCEL * step
	else: # slow to a stop
		var abs_x_velocity : float = absf(velocity.x)
		abs_x_velocity -= WALK_DEACCEL * step
		if abs_x_velocity < 0:
			abs_x_velocity = 0
		velocity.x = signf(velocity.x) * abs_x_velocity
	
	# up / down movement
	if dizzy_input.y < 0:
		if velocity.y > -MAX_WALK_SPEED:
			velocity.y -= WALK_ACCEL * step
	elif dizzy_input.y > 0:
		if velocity.y < MAX_WALK_SPEED: 
			velocity.y += WALK_ACCEL * step
	else: # slow to a stop
		var abs_y_velocity : float = absf(velocity.y)
		abs_y_velocity -= WALK_DEACCEL * step
		if abs_y_velocity < 0:
			abs_y_velocity = 0
		velocity.y = signf(velocity.y) * abs_y_velocity
	
	# TODO: handle jumps
	# TODO: apply z-axis "gravity"
	# TBD how we will find floor contact on z axis and apply physics for things
	# like ice / sand / etc.
	

	state.set_linear_velocity(velocity)
