extends PlayerState

## the collision shape's size when rolling
const ROLLING_COLLISION_SIZE = Vector2(22, 27)
## the collision shape's position when rolling
const ROLLING_COLLISION_POS = Vector2(-4, -13.5)

const ROLLING_SPEED = player.MAX_SPEED * 1.5
const ROLLING_SPEED_SCALE = 1
 
var max_roll_time := 0.0
var roll_timer := 0.0



func enter() -> void :
	player.animation_player.play(ROLLING.to_lower())
	player.animation_player.speed_scale = ROLLING_SPEED_SCALE
	player.set_collision_shape(ROLLING_COLLISION_POS, ROLLING_COLLISION_SIZE)
	max_roll_time = (player.animation_player.current_animation_length / ROLLING_SPEED_SCALE)
	roll_timer = 0.0



func physics_update(delta:float) -> void :
	player.set_collision_orientation(ROLLING_COLLISION_POS)
	player.velocity.y += player.GRAVITY * delta
	player.velocity.x += (ROLLING_SPEED * player.direction.x) * delta
	roll_timer += delta
	player.move_and_slide()
	if roll_timer > max_roll_time:
		finished.emit(IDLE)


func exit() -> void :
	player.animation_player.speed_scale = 1.0
