extends PlayerState


func enter() -> void:
	player.animation_player.play(IDLE.to_lower())
	player.velocity = Vector2.ZERO


func physics_update(delta :float) -> void :
	if not player.is_on_floor():
		finished.emit(FALLING)
	else:
		if Input.is_action_just_pressed("jump"):
			finished.emit(JUMPING)
		if Input.is_action_just_pressed("move_left") or Input.is_action_just_pressed("move_right") :
			finished.emit(RUNNING)
