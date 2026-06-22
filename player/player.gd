extends RigidBody2D

const MAX_WALK_SPEED : float = 200.0
const WALK_ACCEL : float = 1000.0
const WALK_DEACCEL : float = 1000.0
# not convinced this should actually be a thing
const MAX_RUN_SPEED : float = 400.0
const RUN_ACCEL : float = 500.0


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


func _integrate_forces(state: PhysicsDirectBodyState2D) -> void:
	var velocity := state.get_linear_velocity()
	var step := state.get_step()
	
	# player inputs
	var holding_left := Input.is_action_pressed("left")
	var holding_right := Input.is_action_pressed("right")
	var holding_down := Input.is_action_pressed("down")
	var holding_up := Input.is_action_pressed("up")
	
	# left / right movement
	if holding_left and !holding_right:
		if velocity.x > -MAX_WALK_SPEED:
			velocity.x -= WALK_ACCEL * step
	elif holding_right and !holding_left:
		if velocity.x < MAX_WALK_SPEED:
			velocity.x += WALK_ACCEL * step
	else: # slow to a stop
		var abs_x_velocity : float = absf(velocity.x)
		abs_x_velocity -= WALK_DEACCEL * step
		if abs_x_velocity < 0:
			abs_x_velocity = 0
		velocity.x = signf(velocity.x) * abs_x_velocity
	
	# up / down movement
	if holding_up and !holding_down:
		if velocity.y > -MAX_WALK_SPEED:
			velocity.y -= WALK_ACCEL * step
	elif holding_down and !holding_up:
		if velocity.y < MAX_WALK_SPEED:
			velocity.y += WALK_ACCEL * step
	else: # slow to a stop
		var abs_y_velocity : float = absf(velocity.y)
		abs_y_velocity -= WALK_DEACCEL * step
		if abs_y_velocity < 0:
			abs_y_velocity = 0
		velocity.y = signf(velocity.y) * abs_y_velocity
	
	# TBD how we will find floor contact on z axis and apply physics for things
	# like ice / sand / etc.
	
	# TODO: apply z-axis "gravity"
	state.set_linear_velocity(velocity)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
