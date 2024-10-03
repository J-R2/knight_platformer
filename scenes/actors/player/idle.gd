extends PlayerState


func enter() -> void:
	# play the idle animation and set the collision size/orientation
	player.animation_player.play(IDLE.to_lower())
	player.set_collision_shape()


func physics_update(delta :float) -> void :
	if not player.is_on_floor():
		finished.emit(FALLING)
	else:
		if Input.is_action_just_pressed("jump"):
			finished.emit(JUMPING)
		if Input.is_action_just_pressed("crouch"):
			finished.emit(CROUCHING)
		# don't change state if movement is effectively 0
		if Input.is_action_pressed("move_left") and Input.is_action_pressed("move_right") :
			return
		if Input.is_action_pressed("move_left") or Input.is_action_pressed("move_right") :
			finished.emit(RUNNING)
