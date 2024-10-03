extends PlayerState


func enter() -> void :
	player.animation_player.play(RUNNING.to_lower())
	player.set_collision_shape()



func physics_update(delta: float) -> void:
	player.set_collision_orientation()
	# get the running direction from the user input
	var move_direction := Vector2(Input.get_axis("move_left", "move_right"), 0)
	if move_direction.sign() != Vector2.ZERO:
		player.direction.x = move_direction.sign().x
		
	# add the gravity
	player.velocity.y += player.GRAVITY * delta
	# move the player
	player.velocity.x = move_direction.x * player.speed
	player.move_and_slide()
	
	# if not moving or pushing left and right simultaneously
	if is_equal_approx(move_direction.x, 0.0) or (Input.is_action_pressed("move_left") and Input.is_action_pressed("move_right")):
		finished.emit(IDLE)
		
	if Input.is_action_just_pressed("jump"):
		finished.emit(JUMPING)
	if Input.is_action_just_pressed("crouch"):
		finished.emit(SLIDING)
