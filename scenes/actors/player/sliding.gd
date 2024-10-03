extends PlayerState

const SLIDING_FORCE := 80.0 ## the sliding force
const SLIDING_DISTANCE := 50.0 ## the max distance to slide

const SLIDING_COLLISION_SIZE = Vector2(24, 24)
const SLIDING_COLLISION_POS = Vector2(1, -12)

## tracks the distance of the current slide
var _distance_travelled := 0.0

var next_state :String = IDLE

func enter() -> void :
	# reset the distance travelled
	_distance_travelled = 0.0
	# play the animation and set the collision size
	player.animation_player.play(SLIDING.to_lower())
	player.set_collision_shape(SLIDING_COLLISION_POS, SLIDING_COLLISION_SIZE)
	next_state = IDLE


func physics_update(delta :float) -> void :
	player.set_collision_orientation(SLIDING_COLLISION_POS)
	# add gravity
	player.velocity.y += player.GRAVITY
	player.velocity.x += (SLIDING_FORCE * player.direction.x) * delta
	_distance_travelled += SLIDING_FORCE * delta
	player.move_and_slide()
	
	if Input.is_action_just_pressed("crouch") : #TODO if player in crouch_only area
		next_state = CROUCHING
	if Input.is_action_just_pressed("jump") : #TODO unable to jump if player in crouch_only area
		finished.emit(JUMPING)
	if _distance_travelled > SLIDING_DISTANCE: #TODO crouch_only area
		finished.emit(next_state)
	
