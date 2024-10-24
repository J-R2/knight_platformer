class_name Player
extends CharacterBody2D

signal health_changed(new_health)
signal stamina_changed(new_stamina)

const MAX_SPEED := 150.0 ## player's max speed, pixel/second
@export var speed := MAX_SPEED ## player speed, pixel/second

# ==================================================== HEALTH STATS
const MAX_HEALTH :float = 100.0 ## the max value of player's health
var health :float = MAX_HEALTH : ## the current value of player's health
	set(value) :
		health = clampf(value, 0, MAX_HEALTH)
		health_changed.emit(health)
	get:
		return health
# ==================================================== STAMINA STATS
const STAMINA_RECOVERY_COOLDOWN_TIME :float = 1.2 ## how long to wait until stamina recovery after stamina drain
const STAMINA_RECOVERY_RATE :float = 15.0 ## how many stamina points per second to recover while is_stamina_recovery_able
var is_stamina_recovery_able :bool = true ## is the player able to recover stamina
const MAX_STAMINA :float = 100.0 ## the max value of player's stamina
var stamina :float = MAX_STAMINA : ## the current value of player's stamina
	set(value) :
		if value < stamina: # restart the cooldown timer only if the player is losing stamina
			_reset_stamina_recovery_cooldown_timer()
		stamina = clampf(value, 0, MAX_STAMINA)
		stamina_changed.emit(stamina)
	get:
		return stamina


const GRAVITY := 900.0 ## the gravity
const DEFAULT_COLLISION_POS := Vector2(-5, -19) ## the default position of the collision shape
const DEFAULT_COLLISION_SIZE := Vector2(18, 38) ##NOTICE deprecated
const DEFAULT_COLLISION_RADIUS :int = 8 ## the default size of the collision_shape2d
const DEFAULT_COLLISION_HEIGHT :int = 38 ## the default size of the collision_shape2d

const DIALOGUE_ICON = preload("res://scenes/actors/player/art/icons/talk.png") ## icon to display when player enters dialogue_interaction_area

var direction := Vector2.RIGHT ## keeps track of the players facing direction left or right, sign()ed

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D
@onready var wall_climb_detector: Area2D = $WallClimbDetector
@onready var wall_climb_detector_shape_2d: CollisionShape2D = $WallClimbDetector/WallClimbDetectorShape2D
@onready var attack_area: Area2D = $AttackArea
@onready var attack_area_shape_2d: CollisionShape2D = $AttackArea/AttackAreaShape2D
@onready var interaction_area: Area2D = $InteractionArea
@onready var icon: Sprite2D = $Icon
@onready var _stamina_recovery_cooldown_timer: Timer = $StaminaRecoveryCooldownTimer
@onready var player_status_bar: Control = $StatusBarCanvasLayer/PlayerStatusBar
@onready var player_state_machine: StateMachine = $StateMachine


#================================================================================ TESTING
@onready var state_label: Label = $StateLabel
#================================================================================ END TESTING


func _ready() -> void:
	# set the collision shapes default values
	set_collision_shape()
	icon.hide() # hide the player interaction icon
	# connect the signals for player interaction with interactables
	interaction_area.area_entered.connect(_on_interaction_area_entered)
	interaction_area.area_exited.connect(_on_interaction_area_exited)
	# connect the stamina_recovery_cooldown_timer to enable stamina recovery
	_stamina_recovery_cooldown_timer.timeout.connect(func() -> void : is_stamina_recovery_able = true)
	wall_climb_detector.area_entered.connect(_on_wall_climb_detector_area_entered)
	attack_area.area_entered.connect(_on_attack_area_entered)


func _on_attack_area_entered(area:Area2D) -> void :
	if player_state_machine.current_state.has_method("on_attack_area_entered"):
		player_state_machine.current_state.on_attack_area_entered(area)


func _physics_process(delta: float) -> void:
	# set the sprites orientation
	sprite_2d.flip_h = true if direction.x < 0 else false
	# stamina recovery
	if is_stamina_recovery_able and stamina < MAX_STAMINA:
		stamina = move_toward(stamina, MAX_STAMINA, STAMINA_RECOVERY_RATE * delta)

#================================================================================ TESTING
	state_label.text = get_node("StateMachine").current_state.name
	if Input.is_action_just_pressed("use_item"):
		health = MAX_HEALTH
		stamina = MAX_STAMINA
#================================================================================ END TESTING



## Restarts the stamina recovery cooldown timer, disables player is_stamina_recovery_able
func _reset_stamina_recovery_cooldown_timer() -> void :
	is_stamina_recovery_able = false
	_stamina_recovery_cooldown_timer.wait_time = STAMINA_RECOVERY_COOLDOWN_TIME
	_stamina_recovery_cooldown_timer.start()


## Adds the amount to stamina.
func change_stamina(amount:float) -> void :
	stamina = stamina + amount


## Subtracts the amount from health.
func take_damage(amount:float) -> void :
	health = health - amount
	

## does the player have full health and stamina
func has_max_stats() -> bool :
	return (
		health == MAX_HEALTH and 
		stamina == MAX_STAMINA
	)


## Calls the current states' function definition when the wall climb area is entered.
func _on_wall_climb_detector_area_entered(area:Area2D) -> void :
	if player_state_machine.current_state.has_method("on_wall_climb_detector_area_entered"):
		player_state_machine.current_state.on_wall_climb_detector_area_entered(area)


## Runs when something enters the player's interaction area. - collision mask for interactables only
func _on_interaction_area_entered(area:Area2D) -> void :
	# set the icon texture and show it if available
	icon.texture = null
	if area is DialogueInteractionArea:
		icon.texture = DIALOGUE_ICON
		player_status_bar.hide() # hide the hud during dialogues - NOTICE : not perfect, hidden if player is in dialogue area and taking damage
	if icon.texture: icon.show()
	

## Runs when something exits the player's interaction area. - collision mask for interactables only
func _on_interaction_area_exited(area:Area2D) -> void :
	icon.hide()
	if area is DialogueInteractionArea:
		player_status_bar.show() # enable the hud when a player exits dialogue areas


## takes a Vector2, collision shape position, and moves it to the new position if player is facing left/right
func set_collision_orientation(collision_position :Vector2 = DEFAULT_COLLISION_POS) -> void :
	collision_shape_2d.position.x = collision_position.x * direction.x
	# set the player's wall_detector and attack_area positions based on direction
	const wall_detector_position_x :int = 2
	const attack_area_position_x :int = 26
	wall_climb_detector_shape_2d.position.x = wall_detector_position_x * direction.x
	attack_area_shape_2d.position.x = attack_area_position_x * direction.x


## takes a position, radius, and height, to set the player collision capsule shape for each state
func set_collision_shape(collision_position :Vector2 = DEFAULT_COLLISION_POS, collision_radius :int = DEFAULT_COLLISION_RADIUS, collision_height :int = DEFAULT_COLLISION_HEIGHT):
	collision_shape_2d.position = collision_position
	collision_shape_2d.shape.radius = collision_radius
	collision_shape_2d.shape.height = collision_height
	set_collision_orientation(collision_position)


## get the direction and move the player
func move_player(delta:float) -> void :
	var move_direction := Vector2(Input.get_axis("move_left", "move_right"), 0)
	if move_direction.sign() != Vector2.ZERO:
		direction.x = move_direction.sign().x
	# add the gravity
	velocity.y += GRAVITY * delta
	# set the movement velocity
	velocity.x = move_direction.x * speed
	move_and_slide()
