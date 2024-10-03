extends PlayerState


func enter() -> void :
	# play the falling animation and set the collision size
	player.animation_player.play(FALLING.to_lower())
	player.set_collision_shape()

	

func physics_update(delta :float) -> void :
	# set the collision orientation, in physics since you can turn while mid-air
	player.set_collision_orientation()
	player.move_player(delta)
	# if touching floor and not moving idle, if moving run
	if player.is_on_floor():
		if is_zero_approx(player.velocity.x):
			finished.emit(IDLE)
		else:
			finished.emit(RUNNING)
