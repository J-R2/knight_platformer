extends CharacterBody2D


const SPEED :float = 10.0
const JUMP_FORCE :float = 125.0
const GRAVITY :float = 900.0
enum States {IDLE, PATROL, FOLLOW, ATTACK}
var state := States.IDLE
const MOVE_ANIMATION := "move"
const IDLE_ANIMATION := "idle"

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
var state_time_counter := 0.0
var state_duration := 0.0
var is_player_in_range :bool = false
var direction := Vector2.ZERO
@onready var ray_cast_2d: RayCast2D = $RayCast2D


func _physics_process(delta: float) -> void:
	if is_player_in_range:
		enter_state(States.FOLLOW)
	match state:
		States.IDLE:
			state_time_counter += delta
			if state_time_counter > state_duration:
				enter_state(States.PATROL)
		States.PATROL:
			velocity.x = SPEED * direction.x
			state_time_counter += delta
			if state_time_counter > state_duration:
				enter_state(States.IDLE)
		States.FOLLOW:
			pass
		States.ATTACK:
			pass
		_:
			printerr("Slime State error. fix it.")
	if not is_on_floor():
		velocity.y += GRAVITY * delta
	animated_sprite_2d.flip_h = true if direction.x < 0 else false
	move_and_slide()



func enter_state(new_state:int) -> void :
	randomize()
	state = new_state
	match state:
		States.IDLE:
			animated_sprite_2d.play(IDLE_ANIMATION)
			velocity = Vector2.ZERO
			_reset_state_timer(randf_range(2, 4))
		States.PATROL:
			animated_sprite_2d.play(MOVE_ANIMATION)
			_reset_state_timer(randf_range(3, 5))
			direction = [Vector2.LEFT, Vector2.RIGHT].pick_random()
		States.FOLLOW:
			animated_sprite_2d.play(MOVE_ANIMATION)
		States.ATTACK:
			pass
	ray_cast_2d.target_position.x = 40 * direction.x

func _reset_state_timer(wait_time:float = 2.0) -> void :
	state_time_counter = 0.0
	state_duration = wait_time
