extends PlayerState

const SLIDING_COLLISION_SIZE = Vector2(24, 24)
const SLIDING_COLLISION_POS = Vector2(1, -12)

const SLIDING_SPEED = player.MAX_SPEED * 1.5
const SLIDING_SPEED_SCALE = 1.3

var next_state :String = IDLE
var max_slide_time := 0.0
var slide_timer := 0.0

func enter() -> void :
	# play the animation and set the collision size
	player.animation_player.play(SLIDING.to_lower())
	player.animation_player.speed_scale = SLIDING_SPEED_SCALE
	player.set_collision_shape(SLIDING_COLLISION_POS, SLIDING_COLLISION_SIZE)
	next_state = IDLE
	max_slide_time = (player.animation_player.current_animation_length / SLIDING_SPEED_SCALE) + 0.05
	slide_timer = 0.0

	
	
	
func physics_update(delta :float) -> void :
	player.set_collision_orientation(SLIDING_COLLISION_POS)
	# add gravity
	player.velocity.y += player.GRAVITY
	player.velocity.x += (SLIDING_SPEED * player.direction.x) * delta
	slide_timer += delta
	player.move_and_slide()
	
	if Input.is_action_just_pressed("crouch") : #TODO if player in crouch_only area
		next_state = CROUCHING
	if Input.is_action_just_pressed("jump") : #TODO unable to jump if player in crouch_only area
		finished.emit(JUMPING)
	if slide_timer > max_slide_time:
		finished.emit(next_state)


func exit() -> void :
	player.animation_player.speed_scale = 1.0
