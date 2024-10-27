## A bat, starts in a sleeping state, will wake up when a target enters the enemy_detection_area.
## The bat will follow and attack the target, with a varying hover / flight pattern.
extends Area2D

var health :float = 10.0 ## the health of a bat, 1 hit kill
const DAMAGE_AMOUNT :float = 5.0 ## the damage a bat deals to a target
const SPEED :float = 65.0 ## the bat's speed

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var enemy_detection_area: Area2D = $EnemyDetectionArea ## a large area that detects players
@onready var vision_ray_cast: RayCast2D = $VisionRayCast ## helps visualize a bats destination

var target :Node2D = null ## the bat's target

enum States {SLEEPING, HOVERING, FLYING, ATTACKING} ## all possible states a bat can be in
var state := States.SLEEPING ## keeps track of the current state
var state_time_counter := 0.0 ## counts upwards towards state_duration
var state_duration := 0.0 ## how long to stay in a state
var flight_pattern_destination_position := Vector2.ZERO ## the global position coordinates to fly to during the flying state
var attack_pattern_destination_position := Vector2.ZERO ## the global position coordinates to fly to during an attack - near the targets chest
const ATTACK_SPEED_MULTIPLIER :float = 2.5 ## bats fly faster when attacking

# the animated_sprite animation names as constants
const SLEEPING_ANIMATION := "sleeping"
const HOVERING_ANIMATION := "hovering"
const FLYING_ANIMATION := "flying"
const ATTACKING_ANIMATION := "attacking"

@onready var label: Label = $Label #TESTING for testing purposes, displays the current state


func _ready() -> void :
	set_physics_process(false) # the bat does not need to process if it does not have a target, starts at a sleeping stationary position
	animated_sprite.play(SLEEPING_ANIMATION)
	enemy_detection_area.body_entered.connect(_on_enemy_detection_area_body_entered)
	self.body_entered.connect(_on_attack_area_body_entered) # the bat itself is an attack area



func _physics_process(delta: float) -> void:
	match state:# ====================================================== MATCH STATEMENT
		States.SLEEPING: # ====================================================== SLEEPING STATE
			pass
		States.HOVERING: # ====================================================== HOVERING STATE
			# state duration code
			state_time_counter += delta
			if state_time_counter > state_duration:
				var next_state = [States.FLYING, States.ATTACKING].pick_random()
				enter_state(next_state)
		States.FLYING: # ======================================================== FLYING STATE
			vision_ray_cast.target_position = flight_pattern_destination_position - global_position # visualize flight pattern
			global_position = global_position.move_toward(flight_pattern_destination_position, delta * SPEED) # move the bat
			# state change condition
			if global_position == flight_pattern_destination_position:
				var next_state = [States.HOVERING, States.FLYING, States.ATTACKING].pick_random()
				enter_state(next_state)
		States.ATTACKING: # ===================================================== ATTACKING STATE
			vision_ray_cast.target_position = attack_pattern_destination_position - global_position # visualize attack pattern
			global_position = global_position.move_toward(attack_pattern_destination_position, delta * (SPEED * ATTACK_SPEED_MULTIPLIER)) # move the bat
			# state change condition
			if global_position == attack_pattern_destination_position:
				animated_sprite.frame = 2
				enter_state(States.FLYING)
		_: # a state is somehow not assigned
			printerr("Bat does not have a state. Fix it.")
	# ================================================================== END MATCH STATEMENT



## code that runs 1 time when you enter a different state
func enter_state(new_state:int) -> void :
	randomize()
	state = States.values()[new_state]
	label.text = States.keys()[state] #TESTING
	match state: # ====================================================== MATCH STATEMENT
		States.SLEEPING: # ====================================================== SLEEPING ENTER
			pass
		States.HOVERING: # ====================================================== HOVERING ENTER
			animated_sprite.play(HOVERING_ANIMATION)
			_reset_state_timer(randf_range(0.8, 1.6))
		States.FLYING: # ======================================================== FLYING ENTER
			animated_sprite.play(FLYING_ANIMATION)
			_set_flight_pattern()
		States.ATTACKING: # ===================================================== ATTACKING ENTER
			animated_sprite.stop()
			animated_sprite.animation = ATTACKING_ANIMATION
			animated_sprite.frame = 0
			attack_pattern_destination_position = target.global_position
			attack_pattern_destination_position.y -= 25
			animated_sprite.flip_h = true if (attack_pattern_destination_position.x < global_position.x) else false # flip the sprite
			animated_sprite.frame = 1
		_: # invalid state assignment
			printerr("Invalid attempt to enter a bat state.")
	# ================================================================== END MATCH STATEMENT


## picks a random position above the target, and sets the flight_pattern_destination_position
func _set_flight_pattern() -> void :
	flight_pattern_destination_position = target.global_position # start at target
	flight_pattern_destination_position.y -= randi_range(40, 120) # go up some
	flight_pattern_destination_position.x += [randi_range(-120, -40), randi_range(40, 120)].pick_random() # go left or right some
	vision_ray_cast.target_position = flight_pattern_destination_position - global_position # visualize flight pattern
	animated_sprite.flip_h = true if (flight_pattern_destination_position.x < global_position.x) else false # flip the sprite


## target has been aquired, animates from sleeping state
func _start_combat() -> void :
	var takeoff_direction_x = [-1, 1].pick_random() # bat can curve left or right during a takeoff from sleep position
	# the sleeping sprite frame is upside down, and the hover animation is always upright, this will flip it for beginning takeoff
	animated_sprite.rotation = PI * takeoff_direction_x
	animated_sprite.play(HOVERING_ANIMATION)
	var duration = 1.0 # the duration of the takeoff animation
	# move the bat left or right and rotates during that movement
	var horizontal_tween = create_tween()
	horizontal_tween.set_trans(Tween.TRANS_SINE)
	horizontal_tween.set_parallel(true)
	horizontal_tween.tween_property(animated_sprite, "rotation", 0.0, duration)
	var takeoff_distance_x = 40 * takeoff_direction_x # how far to move left or right during takeoff
	horizontal_tween.tween_property(self, "global_position:x", global_position.x + takeoff_distance_x, duration)
	# move the bat down, then back up partially
	var vertical_tween = create_tween()
	vertical_tween.set_trans(Tween.TRANS_SINE)
	var takeoff_distance_y = 10
	vertical_tween.tween_property(self, "global_position:y", global_position.y + takeoff_distance_y, duration / 2)
	vertical_tween.tween_property(self, "global_position:y", global_position.y - takeoff_distance_y/2, duration / 2)
	# transition to the hovering state after takeoff
	horizontal_tween.finished.connect(func()->void:enter_state(States.HOVERING))


# subtract damage amount from bat's health, and play the hit animation
func take_damage(amount:float) -> void :
	health -= amount
	_play_hit_animation()


#TODO modulate the color / spritesheet has a death animation / blood splatter?
func _play_hit_animation() -> void :
	if health < 0.0 : queue_free()


## the bat made contact with a target
func _on_attack_area_body_entered(body:Node2D) -> void:
	if body is Player:
		body.take_damage(DAMAGE_AMOUNT)


## set the target, enter combat, and turn on physics_process
func _on_enemy_detection_area_body_entered(body:Node2D) -> void :
	if not is_physics_processing():
		set_physics_process(true)
	if body is Player and target == null: # only assign target once #INFO maybe free enemy_detection_area?
		target = body
		_start_combat()
		#_start_movement_tweening() #ALERT breaks the flight state for some reason


#ALERT breaks the flight state for some reason (infinite flight loop)?
## moves the bat up and down after takeoff
func _start_movement_tweening() -> void :
	var tween = create_tween()
	var duration :float = .8
	var _amount := 5
	var y_pos = position.y
	tween.tween_property(self, "position:y", y_pos-_amount, duration / 2)
	tween.tween_property(self, "position:y", y_pos+_amount, duration)
	tween.tween_property(self, "position:y", y_pos, duration / 2)
	tween.set_loops()


## resets the counter to 0 and the new duration to a pre-randomized wait_time
func _reset_state_timer(wait_time:float = 2.0) -> void :
	state_time_counter = 0.0
	state_duration = wait_time
