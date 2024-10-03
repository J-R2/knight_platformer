extends PlayerState


func enter() -> void:
	player.animation_player.play(IDLE.to_lower())
	player.collision_shape_2d.shape.size = player.DEFAULT_COLLISION_SIZE


func physics_update(delta :float) -> void :
	if player.sprite_2d.flip_h == true:
		player.collision_shape_2d.position.x = player.DEFAULT_COLLISION_POS.x * -1
	else :
		player.collision_shape_2d.position = player.DEFAULT_COLLISION_POS

	if not player.is_on_floor():
		finished.emit(FALLING)
	else:
		if Input.is_action_just_pressed("jump"):
			finished.emit(JUMPING)
		if Input.is_action_pressed("move_left") and Input.is_action_pressed("move_right") :
			return
		if Input.is_action_pressed("move_left") or Input.is_action_pressed("move_right") :
			finished.emit(RUNNING)
