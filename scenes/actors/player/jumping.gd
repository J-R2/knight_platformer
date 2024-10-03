extends PlayerState


const JUMP_FORCE := 400.0

func enter() -> void :
	# play the jump animation
	player.animation_player.play(JUMPING.to_lower())
	# set the jumping collision size
	player.set_collision_shape()
	# add the jump force to the y velocity
	player.velocity.y += -JUMP_FORCE
	# move the player
	player.move_and_slide()
	
	
func physics_update(delta:float) -> void :
	player.set_collision_orientation()
	player.move_player(delta)
	# if player has startet going down change to falling state
	if player.velocity.y > 0.0:
		finished.emit(FALLING)
