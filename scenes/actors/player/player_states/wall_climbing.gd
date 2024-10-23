extends PlayerState

const CLIMB_UP_AMOUNT :int = -32
const CLIMB_RIGHT_AMOUNT :int = 25
var duration :float = 0.0

const CLIMB_SPEED_SCALE :float = 1.2

var tween :Tween = null

func enter() -> void :
	player.animation_player.play(WALL_CLIMBING.to_lower())
	player.animation_player.speed_scale = CLIMB_SPEED_SCALE
	duration = player.animation_player.current_animation_length / CLIMB_SPEED_SCALE
	tween = create_tween()
	tween.finished.connect(func() -> void : finished.emit(IDLE))
	_wall_climb()



func physics_update(delta:float) -> void :
	pass



func _wall_climb() -> void :
	var climb_up_pos = player.global_position.y + CLIMB_UP_AMOUNT
	var climb_right_pos = player.global_position.x + (CLIMB_RIGHT_AMOUNT * player.direction.x)
	tween.set_ease(Tween.EASE_OUT_IN)
	tween.set_trans(Tween.TRANS_SINE)
	tween.tween_property(player, "global_position:y", climb_up_pos, duration*.6)
	tween.tween_property(player, "global_position:x", climb_right_pos, duration*.4)
	

func exit() -> void :
	player.animation_player.speed_scale = 1.0
