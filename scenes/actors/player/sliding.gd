extends PlayerState

const SLIDING_FORCE := 80.0
const SLIDING_DISTANCE := 30.0

const SLIDING_COLLISION_SIZE = Vector2(24, 24)
const SLIDING_COLLISION_POS = Vector2(1, -12)

var _distance_travelled := 0.0

func enter() -> void :
	_distance_travelled = 0.0
	player.animation_player.play(SLIDING.to_lower())
	player.collision_shape_2d.shape.size = SLIDING_COLLISION_SIZE



func physics_update(delta :float) -> void :
	player.velocity.y += player.GRAVITY
	if player.direction.x == -1:
		player.velocity.x -= SLIDING_FORCE * delta
	else:
		player.velocity.x += SLIDING_FORCE * delta
	_distance_travelled += SLIDING_FORCE * delta
	player.move_and_slide()
	if player.sprite_2d.flip_h == true:
		player.collision_shape_2d.position.x = SLIDING_COLLISION_POS.x * -1
	else :
		player.collision_shape_2d.position = SLIDING_COLLISION_POS
	if _distance_travelled > SLIDING_DISTANCE:
		finished.emit(IDLE)
