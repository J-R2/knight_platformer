extends PlayerState


const WALL_HANG_STAMINA_DRAIN_AMOUNT :float = 5.0
const WALL_CLIMB_STAMINA_DRAIN_AMOUNT :float = 15.0



func enter() -> void :
	player.velocity = Vector2.ZERO
	player.move_and_slide()
	player.animation_player.play(WALL_HANGING.to_lower())



func physics_update(delta:float) -> void :
	player.change_stamina(-WALL_HANG_STAMINA_DRAIN_AMOUNT*delta)
	if is_zero_approx(player.stamina):
		finished.emit(FALLING)
		return
	if Input.is_action_just_pressed("crouch"):
		finished.emit(FALLING)
	if Input.is_action_just_pressed("jump"):
		if player.stamina > WALL_CLIMB_STAMINA_DRAIN_AMOUNT:
			player.change_stamina(-WALL_CLIMB_STAMINA_DRAIN_AMOUNT)
			finished.emit(WALL_CLIMBING)
