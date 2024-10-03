extends PlayerState

var next_state :String = IDLE


func enter() -> void :
	# play the falling animation and set the collision size
	player.animation_player.play(FALLING.to_lower())
	player.set_collision_shape()
	next_state = IDLE



func physics_update(delta :float) -> void :
	# set the collision orientation, in physics since you can turn while mid-air
	player.set_collision_orientation()
	player.move_player(delta)
	# if touching floor and not moving idle, if moving run
	if next_state != SLIDING:
		if !is_zero_approx(player.velocity.x):
			next_state = RUNNING
	if Input.is_action_just_pressed("crouch"):
		next_state = SLIDING
	if player.is_on_floor():
		finished.emit(next_state)
