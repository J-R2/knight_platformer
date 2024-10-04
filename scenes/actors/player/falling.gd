extends PlayerState

var next_state := IDLE


func enter() -> void :
	# play the falling animation and set the collision size
	player.animation_player.play(FALLING.to_lower())
	player.set_collision_shape()
	next_state = IDLE


func physics_update(delta :float) -> void :
	# set the collision orientation, in physics since you can turn while mid-air
	player.set_collision_orientation()
	player.move_player(delta)
	if Input.is_action_just_pressed("crouch"):
		next_state = SLIDING
	if Input.is_action_just_pressed("roll"):
		next_state = ROLLING
	if player.is_on_floor() and next_state not in [SLIDING, ROLLING]:
		if is_zero_approx(player.velocity.x):
			next_state = IDLE
		else:
			next_state = RUNNING
		finished.emit(next_state)
		return
	elif player.is_on_floor():
		finished.emit(next_state)
