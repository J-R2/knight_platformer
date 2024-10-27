## A Slime monster, it will follow the player once they enter the slime's detection area.
##   If player gets far enough away, the slime will stop following and resume its patrol pattern.
class_name Slime
extends CharacterBody2D

# slime stats
var health :float = 18.0 ## the amount of health a slime has
const SPEED :float = 10.0 ## the speed of a slime monster
const DAMAGE_AMOUNT :float = 5.0 ## the amount of damage a slime deals
const MAX_SIGHT_DISTANCE :float = 200.0 ## the distance away a slime can "see", will lose sight if target is out of range
const FOLLOW_SPEED_MULTIPLIER :float = 1.75
# environment variables
const JUMP_FORCE :float = 125.0 ## the height of a slime's jump
const GRAVITY :float = 900.0 ## the gravity applied to a slime monseter
# slime states
enum States {IDLE, PATROL, FOLLOW} ## all possible states a slime can be in
var state := States.IDLE ## holds the current state, defaulted to idle
var state_time_counter := 0.0 ## will count upwards towards the state_duration
var state_duration := 0.0 ## the duration the slime will stay in a particular state
const MOVE_ANIMATION := "move" ## holds the string name of the slime's move animation
const IDLE_ANIMATION := "idle" ## holds the string name of the slime's idle animation
# attached nodes
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var attack_area: Area2D = $AttackArea
@onready var enemy_detection_area: Area2D = $EnemyDetectionArea
@onready var vision_raycast: RayCast2D = $VisionRayCast
@onready var state_label: Label = $StateLabel
# global variables
@onready var original_modulate :Color = self.modulate ## keeps track of the original color modulation
var direction := Vector2.ZERO ## the direction the slime is facing
var target = null ## the target that the slime will follow


func _ready() -> void :
	enemy_detection_area.body_entered.connect(_on_enemy_detection_area_body_entered)
	attack_area.body_entered.connect(_on_attack_area_body_entered)


func _physics_process(delta: float) -> void:
	if target:
		vision_raycast.target_position = target.global_position - global_position
		vision_raycast.target_position.y -= 20
	match state: # ================================== MATCH STATEMENT
		States.IDLE: # ====================================================== IDLE STATE PROCESS
			# state duration code
			state_time_counter += delta
			if state_time_counter > state_duration:
				enter_state(States.PATROL)
		States.PATROL: # ==================================================== PATROL STATE PROCESS
			velocity.x = SPEED * direction.x
			# state duration code
			state_time_counter += delta
			if state_time_counter > state_duration:
				enter_state(States.IDLE)
		States.FOLLOW: # ==================================================== FOLLOW STATE PROCESS
			var target_position :Vector2 = target.global_position - global_position
			direction.x = target_position.normalized().x # the direction to the target
			if target_position.length() > 2.0:
				velocity.x = (SPEED * FOLLOW_SPEED_MULTIPLIER) * direction.x # set the velocity towards the target's direction
			else:
				velocity.x = 0.0
			if target_position.length() > MAX_SIGHT_DISTANCE: # if target is out of sight range
				enter_state(States.PATROL)
		_: # somehow a state is not assigned?
			printerr("Slime State error. fix it.")
	# =============================================== END MATCH STATEMENT
	# move the slime and set orientation
	if not is_on_floor():
		velocity.y += GRAVITY * delta
	animated_sprite_2d.flip_h = true if direction.x < 0 else false
	move_and_slide()


## code that needs to run 1x when the state changes
func enter_state(new_state:int) -> void :
	state_label.text = States.keys()[new_state]
	randomize()
	state = States.values()[new_state]
	match state:
		States.IDLE: # ====================================================== IDLE STATE ENTER
			_reset_target() # there is no target while a slime is relaxing
			animated_sprite_2d.play(IDLE_ANIMATION)
			velocity = Vector2.ZERO # slimes cannot move during idle
			_reset_state_timer(randf_range(2, 4)) # the duration of the idle state
		States.PATROL: # ==================================================== PATROL STATE ENTER
			_reset_target()
			animated_sprite_2d.play(MOVE_ANIMATION)
			_reset_state_timer(randf_range(3, 5))
			direction = [Vector2.LEFT, Vector2.RIGHT].pick_random() # the direction to go while patrolling
		States.FOLLOW: # ==================================================== FOLLOW STATE ENTER
			animated_sprite_2d.play(MOVE_ANIMATION)
		_: # invalid state
			printerr("Invalid attempt to enter a slime state.")


## resets the slime's target and vision raycast2d
func _reset_target() -> void :
	target = null
	vision_raycast.target_position = Vector2(0, 1)


## subtracts damage amount from health, plays the hit animation
func take_damage(amount:float) -> void :
	health -= amount
	_tween_hit_animation()


## modulates to a reddish "hit" animation, and free() if the slime is dead
func _tween_hit_animation() -> void :
	var tween = create_tween()
	tween.tween_property(self, "modulate", Color.DARK_RED, .2)
	tween.tween_callback(func()->void : if health < 0.0: queue_free())
	tween.tween_property(self, "modulate", original_modulate, .1)


## Attack a target if they enter the slime's attack_area
func _on_attack_area_body_entered(body:Node2D) -> void :
	if body.has_method("take_damage"):
		body.take_damage(DAMAGE_AMOUNT)


## set the target and start following it
func _on_enemy_detection_area_body_entered(body:Node2D) -> void:
	if body is Player:
		target = body
		enter_state(States.FOLLOW)


## resets the state_duration and counter to a pre-randomized countdown
func _reset_state_timer(wait_time:float = 5.0) -> void :
	state_time_counter = 0.0
	state_duration = wait_time
