extends PlayerState

## the collision shape's position when running
const RUNNING_COLLISION_POS = Vector2(-2, -19)
## the collision shape's size when running
const RUNNING_COLLISION_RADIUS := 9
const RUNNING_COLLISION_HEIGHT := 38

const RUNNING_SPEED_SCALE = 1.2

const COYOTE_MAX_TIME :float = 0.5 ## currently used to continue running animation while going down stairs, can be 0 grav for coyote time maybe
var coyote_timer :float = 0.0


func enter() -> void :
	player.animation_player.play(RUNNING.to_lower())
	player.animation_player.speed_scale = RUNNING_SPEED_SCALE
	player.set_collision_shape(RUNNING_COLLISION_POS, RUNNING_COLLISION_RADIUS, RUNNING_COLLISION_HEIGHT)




func physics_update(delta: float) -> void:
	player.set_collision_orientation()
	player.move_player(delta)
	
	# if not moving or pushing left and right simultaneously
	if is_equal_approx(player.velocity.x, 0.0) or (Input.is_action_pressed("move_left") and Input.is_action_pressed("move_right")):
		finished.emit(IDLE)
		return
	if player.is_on_floor() :
		coyote_timer = 0.0
	else:
		coyote_timer += delta
		if coyote_timer > COYOTE_MAX_TIME :
			finished.emit(FALLING)
	if Input.is_action_just_pressed("jump"):
		finished.emit(JUMPING)
	if Input.is_action_just_pressed("crouch"):
		finished.emit(SLIDING)
	if Input.is_action_just_pressed("roll"):
		finished.emit(ROLLING)
	if Input.is_action_just_pressed("attack"):
		finished.emit(ATTACKING)




func exit() -> void :
	player.animation_player.speed_scale = 1.0
	coyote_timer = 0.0
	
