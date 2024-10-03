extends PlayerState




func enter() -> void :
	player.animation_player.play(JUMPING.to_lower())
	player.velocity.y += -player.jump_force
	player.move_and_slide()
	
	
func physics_update(delta:float) -> void :
	# get the move direction from the user input
	var move_direction := Vector2(Input.get_axis("move_left", "move_right"), 0)
	# set the desired velocity
	var desired_velocity := move_direction * player.speed
	# add the gravity
	player.velocity.y += player.GRAVITY * delta
	if move_direction != Vector2.ZERO: # if the player is pressing the move buttons
		player.direction.x = move_direction.x # set the player direction orientation
		player.velocity.x = move_toward(player.velocity.x, desired_velocity.x, player.acceleration * delta) # move the velocity.x towards the desired velocity
	else: # the player is no longer pressing the move buttons
		player.velocity.x = move_toward(player.velocity.x, 0.0, player.deceleration * delta) # decelerate the players velocity
	player.move_and_slide()
	if player.velocity.y > 0.0:
		finished.emit(FALLING)
