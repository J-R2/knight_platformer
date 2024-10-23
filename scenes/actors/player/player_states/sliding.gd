extends PlayerState


const SLIDING_SPEED = player.MAX_SPEED * 1.7 ## player slides faster than walking speed
const SLIDING_SPEED_SCALE = 1.15 ## speed up animation player amount

## the collision shape's position when sliding
const SLIDING_COLLISION_POS = Vector2(-1, -14)
## the collision shape's size when sliding
const SLIDING_COLLISION_RADIUS := 10
const SLIDING_COLLISION_HEIGHT := 28

var next_state :String = IDLE
var state_duration := 0.0 ## max time to slide for
var state_timer := 0.0 ## counts toward slide state duration


func _ready() -> void:
	super._ready()
	await owner.ready
	state_duration = player.animation_player.get_animation(SLIDING.to_lower()).length / SLIDING_SPEED_SCALE
	

func enter() -> void :
	# play the animation and set the collision size
	player.animation_player.play(SLIDING.to_lower())
	player.animation_player.speed_scale = SLIDING_SPEED_SCALE
	player.set_collision_shape(SLIDING_COLLISION_POS, SLIDING_COLLISION_RADIUS, SLIDING_COLLISION_HEIGHT)
	
	
func physics_update(delta :float) -> void :
	player.set_collision_orientation(SLIDING_COLLISION_POS)
	# add gravity
	player.velocity.y += player.GRAVITY * delta
	# slide the player in their direction
	player.velocity.x = (SLIDING_SPEED * player.direction.x)	
	player.move_and_slide()
	# player can transition to these things during a slide
	if Input.is_action_just_pressed("crouch") : #TODO if player in crouch_only area
		next_state = CROUCHING # wait until done sliding
	if Input.is_action_just_pressed("jump") : #TODO unable to jump if player in crouch_only area
		finished.emit(JUMPING) # can jump, interrupting a slide
	# count towards state duration, then change states
	state_timer += delta
	if state_timer > state_duration:
		finished.emit(next_state)


func exit() -> void :
	player.animation_player.speed_scale = 1.0
	state_timer = 0.0
	next_state = IDLE
