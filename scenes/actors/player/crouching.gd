extends PlayerState


const CROUCHING_COLLISION_SIZE = Vector2(22, 27)
const CROUCHING_COLLISION_POS = Vector2(-4, -13.5)

func enter() -> void :
	player.animation_player.play(SLIDING.to_lower())
	player.collision_shape_2d.shape.size = CROUCHING_COLLISION_SIZE


func physics_update(delta :float) -> void :
	if player.sprite_2d.flip_h == true:
		player.collision_shape_2d.position.x = CROUCHING_COLLISION_POS.x * -1
	else :
		player.collision_shape_2d.position = CROUCHING_COLLISION_POS
