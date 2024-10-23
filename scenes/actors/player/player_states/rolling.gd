extends PlayerState

const ROLLING_STAMINA_COST := 8.0 ## Stamina cost of rolling.
const ROLLING_SPEED = player.MAX_SPEED * 2.0 ## player moves faster while rolling
const ROLLING_SPEED_SCALE = 1.1 # had to speed up the animation, easier to do it here than in animation player

## the collision shape's position when rolling
const ROLLING_COLLISION_POS = Vector2(-1, -17)
## the collision shape's size when rolling
const ROLLING_COLLISION_RADIUS := 8
const ROLLING_COLLISION_HEIGHT := 34

var state_duration := 0.0
var state_timer := 0.0



func _ready() -> void:
	super._ready()
	await owner.ready
	state_duration = player.animation_player.get_animation(ROLLING.to_lower()).length / ROLLING_SPEED_SCALE


func enter() -> void :
	# expend stamina on roll
	if player.stamina < ROLLING_STAMINA_COST / 2:
		finished.emit(get_parent().previous_state)
		return
	player.change_stamina(-ROLLING_STAMINA_COST)
	# play the animation and set the animation speed scale
	player.animation_player.play(ROLLING.to_lower())
	player.animation_player.speed_scale = ROLLING_SPEED_SCALE
	# set the rolling collision shape
	player.set_collision_shape(ROLLING_COLLISION_POS, ROLLING_COLLISION_RADIUS, ROLLING_COLLISION_HEIGHT)
	

func physics_update(delta:float) -> void :
	player.set_collision_orientation(ROLLING_COLLISION_POS)
	player.velocity.y += player.GRAVITY * delta
	player.velocity.x = (ROLLING_SPEED * player.direction.x)
	player.move_and_slide()
	# count towards state duration then exit state
	state_timer += delta
	if state_timer > state_duration:
		finished.emit(IDLE)


func exit() -> void :
	player.animation_player.speed_scale = 1.0
	state_timer = 0.0
