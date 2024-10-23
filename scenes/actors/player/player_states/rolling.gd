extends PlayerState


## the collision shape's position when rolling
const ROLLING_COLLISION_POS = Vector2(-1, -17)
## the collision shape's size when rolling
const ROLLING_COLLISION_RADIUS := 8
const ROLLING_COLLISION_HEIGHT := 34

const ROLLING_SPEED = player.MAX_SPEED * 1.7
const ROLLING_SPEED_SCALE = 1.1
 
var max_roll_time := 0.0
var roll_timer := 0.0

const ROLLING_STAMINA_COST := 8.0


func enter() -> void :
	if player.stamina < ROLLING_STAMINA_COST / 2:
		finished.emit(get_parent().previous_state)
		return
	player.change_stamina(-ROLLING_STAMINA_COST)
	player.animation_player.play(ROLLING.to_lower())
	player.animation_player.speed_scale = ROLLING_SPEED_SCALE
	player.set_collision_shape(ROLLING_COLLISION_POS, ROLLING_COLLISION_RADIUS, ROLLING_COLLISION_HEIGHT)
	max_roll_time = (player.animation_player.current_animation_length / ROLLING_SPEED_SCALE)
	roll_timer = 0.0



func physics_update(delta:float) -> void :
	player.set_collision_orientation(ROLLING_COLLISION_POS)
	player.velocity.y += player.GRAVITY * delta
	player.velocity.x = (ROLLING_SPEED * player.direction.x)
	roll_timer += delta
	player.move_and_slide()
	if roll_timer > max_roll_time:
		finished.emit(IDLE)


func exit() -> void :
	player.animation_player.speed_scale = 1.0
