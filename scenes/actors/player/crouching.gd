extends PlayerState


## the collision shape's position when crouching
const CROUCHING_COLLISION_POS = Vector2(-3, -14)
## the collision shape's size when crouching
const CROUCHING_COLLISION_RADIUS := 9
const CROUCHING_COLLISION_HEIGHT := 28
const CROUCHING_SPEED = player.MAX_SPEED * .4


func enter() -> void :
	# play the "crouching" animation and set the collision size
	_reset_crouch_animation()
	player.set_collision_shape(CROUCHING_COLLISION_POS, CROUCHING_COLLISION_RADIUS, CROUCHING_COLLISION_HEIGHT)
	player.speed = CROUCHING_SPEED
	

func exit() -> void :
	player.speed = player.MAX_SPEED


func physics_update(delta :float) -> void :
	player.set_collision_orientation(CROUCHING_COLLISION_POS)
	player.move_player(delta)
	if ! is_zero_approx(player.velocity.x):
		player.animation_player.play(CROUCHING.to_lower())
	else:
		_reset_crouch_animation()
	if Input.is_action_just_pressed("crouch") or Input.is_action_just_pressed("jump"):
		finished.emit(IDLE)
	

func _reset_crouch_animation() -> void :
	player.animation_player.play(CROUCHING.to_lower())
	player.animation_player.seek(0.0)
	player.animation_player.stop()
