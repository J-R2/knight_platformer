extends PlayerState

## the collision shape's position when crouching
const CROUCHING_COLLISION_POS = Vector2(-3, -14)
## the collision shape's size when crouching
const CROUCHING_COLLISION_RADIUS := 9
const CROUCHING_COLLISION_HEIGHT := 28
## the player moves slower while crouching
const CROUCHING_SPEED = player.MAX_SPEED * .4


func enter() -> void :
	# start the crouching animation
	_reset_crouch_animation()
	# set the crouching collision shape
	player.set_collision_shape(CROUCHING_COLLISION_POS, CROUCHING_COLLISION_RADIUS, CROUCHING_COLLISION_HEIGHT)
	# slow the player down while crouching
	player.speed = CROUCHING_SPEED


func physics_update(delta :float) -> void :
	# set the crouching collision shape's orientation
	player.set_collision_orientation(CROUCHING_COLLISION_POS)
	# player can move while crouching
	player.move_player(delta)
	# play the animation if moving, reset to first frame if not moving
	if ! is_zero_approx(player.velocity.x):
		player.animation_player.play(CROUCHING.to_lower())
	else:
		_reset_crouch_animation()
	# stand up on player input
	if Input.is_action_just_pressed("crouch") or Input.is_action_just_pressed("jump"):
		finished.emit(IDLE)
	# can roll if crouched
	if Input.is_action_just_pressed("roll"):
		finished.emit(ROLLING)
	

## Reset to, and pause crouch animation on first frame.
func _reset_crouch_animation() -> void :
	player.animation_player.play(CROUCHING.to_lower())
	player.animation_player.seek(0.0)
	player.animation_player.stop()


func exit() -> void :
	# reset the variables to default
	player.speed = player.MAX_SPEED
