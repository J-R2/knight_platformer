extends PlayerState


func enter() -> void :
	# play the falling animation and set the collision size
	player.animation_player.play(FALLING.to_lower())
	player.collision_shape_2d.shape.size = player.DEFAULT_COLLISION_SIZE

	

func physics_update(delta :float) -> void :
	# set the collision orientation, in physics since you can turn while mid-air
	if player.sprite_2d.flip_h == true:
		player.collision_shape_2d.position.x = player.DEFAULT_COLLISION_POS.x * -1
	else :
		player.collision_shape_2d.position = player.DEFAULT_COLLISION_POS
	# get the move direction from the user input
	var move_direction := Vector2(Input.get_axis("move_left", "move_right"), 0)
	if move_direction.sign() != Vector2.ZERO:
		player.direction.x = move_direction.sign().x
	# add the gravity
	player.velocity.y += player.GRAVITY * delta
	# move the player
	player.velocity.x = move_direction.x * player.speed
	player.move_and_slide()
	# if touching floor and not moving idle, if moving run
	if player.is_on_floor():
		if is_zero_approx(move_direction.x):
			finished.emit(IDLE)
		else:
			finished.emit(RUNNING)
