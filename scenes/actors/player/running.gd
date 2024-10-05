extends PlayerState

## the collision shape's position when running
const RUNNING_COLLISION_POS = Vector2(-2, -19)
## the collision shape's size when running
const RUNNING_COLLISION_RADIUS := 9
const RUNNING_COLLISION_HEIGHT := 38


func enter() -> void :
	player.animation_player.play(RUNNING.to_lower())
	player.set_collision_shape(RUNNING_COLLISION_POS, RUNNING_COLLISION_RADIUS, RUNNING_COLLISION_HEIGHT)




func physics_update(delta: float) -> void:
	player.set_collision_orientation()
	player.move_player(delta)
	
	# if not moving or pushing left and right simultaneously
	if is_equal_approx(player.velocity.x, 0.0) or (Input.is_action_pressed("move_left") and Input.is_action_pressed("move_right")):
		finished.emit(IDLE)
		return
	if Input.is_action_just_pressed("jump"):
		finished.emit(JUMPING)
	if Input.is_action_just_pressed("crouch"):
		finished.emit(SLIDING)
	if Input.is_action_just_pressed("roll"):
		finished.emit(ROLLING)
