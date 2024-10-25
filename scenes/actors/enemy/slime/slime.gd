extends CharacterBody2D

const DAMAGE_AMOUNT :float = 5.0 ## the amount of damage a slime deals
var health :float = 18.0 ## the amount of health a slime has
const SPEED :float = 10.0 ## the speed of a slime monster
const FOLLOW_SPEED_MULTIPLIER :float = 1.0
const JUMP_FORCE :float = 125.0 ## the height of a slime's jump
const GRAVITY :float = 900.0 ## the gravity applied to a slime monseter

enum States {IDLE, PATROL, FOLLOW, ATTACK} ## all possible states a slime can be in
var state := States.IDLE ## holds the current state, defaulted to idle
const MOVE_ANIMATION := "move" ## holds the string name of the slime's move animation
const IDLE_ANIMATION := "idle" ## holds the string name of the slime's idle animation

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var original_modulate :Color = self.modulate

var state_time_counter := 0.0 ## will count upwards towards the state_duration
var state_duration := 0.0 ## the duration the slime will stay in a particular state
var direction := Vector2.ZERO ## the direction the slime is facing
@onready var attack_area: Area2D = $AttackArea
@onready var enemy_detection_area: Area2D = $EnemyDetectionArea
var player :Player = null
var is_player_in_range :bool = false


@onready var label: Label = $Label



func _ready() -> void :
	enemy_detection_area.body_entered.connect(_on_enemy_detection_area_body_entered)
	enemy_detection_area.body_exited.connect(_on_enemy_detection_area_body_exited)
	attack_area.body_entered.connect(_on_attack_area_body_entered)
	player = get_tree().get_first_node_in_group("player")


# =========================================================================== PHYSICS PROCESS
func _physics_process(delta: float) -> void:
	match state: # ========================================================== MATCH
		States.IDLE: # ====================================================== IDLE STATE
			# state duration code
			state_time_counter += delta
			if state_time_counter > state_duration:
				enter_state(States.PATROL)
		States.PATROL: # ==================================================== PATROL STATE
			velocity.x = SPEED * direction.x
			# state duration code
			state_time_counter += delta
			if state_time_counter > state_duration:
				enter_state(States.IDLE)
		States.FOLLOW: # ==================================================== FOLLOW STATE
			direction.x = (player.global_position - global_position).normalized().x
			velocity.x = (SPEED * FOLLOW_SPEED_MULTIPLIER) * direction.x
			if not is_player_in_range:
				state_time_counter += delta
				if state_time_counter > state_duration:
					enter_state(States.PATROL)
		States.ATTACK: # ==================================================== ATTACK STATE
			pass
		_:
			printerr("Slime State error. fix it.")
	# ======================================================================= END MATCH
	# move the slime and set orientation
	if not is_on_floor():
		velocity.y += GRAVITY * delta
	animated_sprite_2d.flip_h = true if direction.x < 0 else false
	move_and_slide()


## code that needs to run 1x when the state changes to a new state
func enter_state(new_state:int) -> void :
	label.text = States.keys()[new_state]
	randomize()
	state = new_state
	match state:
		States.IDLE: # ====================================================== IDLE STATE
			animated_sprite_2d.play(IDLE_ANIMATION)
			velocity = Vector2.ZERO
			_reset_state_timer(randf_range(2, 4))
		States.PATROL: # ==================================================== PATROL STATE
			animated_sprite_2d.play(MOVE_ANIMATION)
			_reset_state_timer(randf_range(3, 5))
			direction = [Vector2.LEFT, Vector2.RIGHT].pick_random()
		States.FOLLOW: # ==================================================== FOLLOW STATE
			animated_sprite_2d.play(MOVE_ANIMATION)
		States.ATTACK: # ==================================================== ATTACK STATE
			pass


func take_damage(amount:float) -> void :
	health -= amount
	_tween_hit_animation()
	if health < 0.0:
		queue_free()


func _tween_hit_animation() -> void :
	var tween = create_tween()
	tween.tween_property(self, "modulate", Color.DARK_RED, .2)
	tween.tween_property(self, "modulate", original_modulate, .1)


func _on_attack_area_body_entered(body:Node2D) -> void :
	if body.has_method("take_damage"):
		body.take_damage(DAMAGE_AMOUNT)


func _on_enemy_detection_area_body_entered(body:Node2D) -> void:
	if body is Player:
		is_player_in_range = true
		enter_state(States.FOLLOW)


func _on_enemy_detection_area_body_exited(body:Node2D) -> void :
	if body is Player:
		is_player_in_range = false
		_reset_state_timer(4.0)


## resets the state_duration and counter to a pre-randomized countdown
func _reset_state_timer(wait_time:float = 2.0) -> void :
	state_time_counter = 0.0
	state_duration = wait_time
