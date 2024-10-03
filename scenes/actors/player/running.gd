extends PlayerState


func enter() -> void :
	player.animation_player.play(RUNNING.to_lower())



func physics_update(delta: float) -> void:
	# get the running direction from the user input
	var running_direction := Vector2(Input.get_axis("move_left", "move_right"), 0)
	# set the desired velocity
	var desired_velocity := running_direction * player.speed
	# add the gravity
	player.velocity.y += player.GRAVITY * delta
	if running_direction != Vector2.ZERO: # if the player is pressing the move buttons
		player.direction.x = running_direction.x # set the player direction orientation
		player.velocity.x = move_toward(player.velocity.x, desired_velocity.x, player.acceleration * delta) # move the velocity.x towards the desired velocity
	else: # the player is no longer pressing the move buttons
		player.velocity.x = move_toward(player.velocity.x, 0.0, player.deceleration * delta) # decelerate the players velocity
	# if the player is not pressing buttons and the sprite has stopped moving, change to IDLE state
	if running_direction.is_zero_approx() and is_equal_approx(player.velocity.x, 0.0):
		finished.emit(IDLE)
	if Input.is_action_just_pressed("jump"):
		finished.emit(JUMPING)
	player.move_and_slide()
