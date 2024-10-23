extends PlayerState

const CLIMB_UP_AMOUNT :int = -32 ## player moves up by this amount
const CLIMB_RIGHT_AMOUNT :int = 25 ## player moves to the side this amount
var state_duration :float = 0.0 ## how long the climb state lasts

const CLIMB_SPEED_SCALE :float = 1.2 ## speed up the animation player to this amount

func _ready() -> void :
	super._ready()
	await owner.ready
	state_duration = player.animation_player.get_animation(WALL_CLIMBING.to_lower()).length / CLIMB_SPEED_SCALE

func enter() -> void :
	player.animation_player.play(WALL_CLIMBING.to_lower())
	player.animation_player.speed_scale = CLIMB_SPEED_SCALE
	_wall_climb()


## Tweens the player's position up and to the side by CLIMB_AMOUNTs, then transitions to IDLE
func _wall_climb() -> void :
	var tween = create_tween()
	var climb_up_pos = player.global_position.y + CLIMB_UP_AMOUNT
	var climb_right_pos = player.global_position.x + (CLIMB_RIGHT_AMOUNT * player.direction.x)
	tween.set_ease(Tween.EASE_OUT_IN)
	tween.set_trans(Tween.TRANS_SINE)
	tween.tween_property(player, "global_position:y", climb_up_pos, state_duration*.6)
	tween.tween_property(player, "global_position:x", climb_right_pos, state_duration*.4)
	tween.finished.connect(func() -> void : finished.emit(IDLE))
	

func exit() -> void :
	player.animation_player.speed_scale = 1.0
