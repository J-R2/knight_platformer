extends PlayerState


func enter() -> void :
	player.velocity = Vector2.ZERO
	player.move_and_slide()
	player.animation_player.play(WALL_HANGING.to_lower())


func physics_update(delta:float) -> void :
	if Input.is_action_just_pressed("crouch"):
		finished.emit(FALLING)
	if Input.is_action_just_pressed("jump"):
		finished.emit(JUMPING)
