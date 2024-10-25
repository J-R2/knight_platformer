extends PlayerState

const ATTACK_STAMINA_COST :float = 7.0 ## The stamina cost of a light attack.
const MAX_ATTACK_DAMAGE :float = 25.0
const MIN_ATTACK_DAMAGE :float = 10.0

var state_duration :float = 1.0 ## The length of the attack animation, RESET on state enter and animation has been set
var state_timer :float = 0.0 ## Counts up by delta, until reaches state_duration, then transition to next state
var next_state := IDLE ## The state to transition to after state duration timer is reached.


func _ready() -> void:
	super._ready()
	await owner.ready
	state_duration = player.animation_player.get_animation(ATTACKING.to_lower()).length
	

func enter() -> void :
	# must have at least half of the attack stamina cost in order to attack
	if player.stamina < ATTACK_STAMINA_COST / 2:
		finished.emit(IDLE)
		return
	player.change_stamina(-ATTACK_STAMINA_COST) # attacking causes stamina drain
	player.attack_area_shape_2d.set_deferred("disabled", false)
	player.animation_player.play(ATTACKING.to_lower())
	

func physics_update(delta:float) -> void :
	state_timer += delta # count towards the state_duration
	if Input.is_action_just_pressed("attack"): # queue the follow up attack if double tap "attack" key
		next_state = ATTACKING_2
	if state_timer > state_duration: # transition to next state when attack animation is finished
		finished.emit(next_state)



func on_attack_area_area_entered(area:Area2D):
	print("Normal attack: ", randi_range(MIN_ATTACK_DAMAGE, MAX_ATTACK_DAMAGE), " damage to ", area.name)
	player.attack_area_shape_2d.set_deferred("disabled", true)


func on_attack_area_body_entered(body:Node2D):
	player.attack_area_shape_2d.set_deferred("disabled", true)
	if body.has_method("take_damage"):
		body.take_damage(randi_range(MIN_ATTACK_DAMAGE, MAX_ATTACK_DAMAGE))


func exit() -> void :
	# reset the variables to default values
	next_state = IDLE
	player.attack_area_shape_2d.set_deferred("disabled", true)
	state_timer = 0.0
