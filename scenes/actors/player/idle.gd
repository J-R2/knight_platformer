extends PlayerState


var collision := Vector2.ZERO
var touching_wall :bool = false

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
		if Input.is_action_just_pressed("roll"):
			finished.emit(ROLLING)
		if Input.is_action_just_pressed("attack"):
			finished.emit(ATTACKING)
		if Input.is_action_pressed("move_left") and Input.is_action_pressed("move_right") :
			finished.emit(IDLE)
			return
		if Input.is_action_pressed("move_left") or Input.is_action_pressed("move_right") :
			if player.is_on_wall():
				collision = player.get_last_slide_collision().get_normal()
				collision.x *= -1
				touching_wall = true
			if touching_wall == true:
				if collision.x == 1 and Input.is_action_pressed("move_left"):
					touching_wall = false
					finished.emit(RUNNING)
				elif collision.x == -1 and Input.is_action_pressed("move_right"):
					touching_wall = false
					finished.emit(RUNNING)
			else:
				finished.emit(RUNNING)
