extends PlayerState

var collision := Vector2.ZERO ## holds the last collision between player and a wall


func enter() -> void:
	# play the idle animation and set the collision size/orientation
	player.animation_player.play(IDLE.to_lower())
	player.set_collision_shape()


func physics_update(delta :float) -> void :
	if not player.is_on_floor(): # fall if not on floor
		finished.emit(FALLING)
	else: # player can do these things if on the floor
		if Input.is_action_just_pressed("jump"):
			finished.emit(JUMPING)
		if Input.is_action_just_pressed("crouch"):
			finished.emit(CROUCHING)
		if Input.is_action_just_pressed("roll"):
			finished.emit(ROLLING)
		if Input.is_action_just_pressed("attack"):
			finished.emit(ATTACKING)
		# stand still if trying to move both left and right simultaneously
		if Input.is_action_pressed("move_left") and Input.is_action_pressed("move_right") :
			finished.emit(IDLE)
			return
		# if only pressing move left OR right do this
		if Input.is_action_pressed("move_left") or Input.is_action_pressed("move_right") :
			if player.is_on_wall():
				# get the direction of the wall, x*-1 since originally from wall's perspective
				collision = player.get_last_slide_collision().get_normal()
				collision.x *= -1
				# can only move left if wall is on right
				if collision.x == 1 and Input.is_action_pressed("move_left"):
					finished.emit(RUNNING)
				# can only move right if wall is on left
				elif collision.x == -1 and Input.is_action_pressed("move_right"):
					finished.emit(RUNNING)
			else: # if player is not on wall and pressing move
				finished.emit(RUNNING)
