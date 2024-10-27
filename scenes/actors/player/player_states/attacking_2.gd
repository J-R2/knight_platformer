extends PlayerState

var state_duration :float = 1.0 ## The length of the attack animation, RESET on state enter and animation has been set
var state_timer :float = 0.0 ## Counts up by delta, until reaches state_duration, then transition to next state
const STRONG_ATTACK_STAMINA_COST :float = 10.0 ## The stamina cost of a strong attack.
const MAX_ATTACK_DAMAGE :float = 40.0
const MIN_ATTACK_DAMAGE :float = 25.0


func _ready() -> void:
	super._ready()
	await owner.ready
	state_duration = player.animation_player.get_animation(ATTACKING_2.to_lower()).length


func enter() -> void :
	# must have at least half of the strong attack stamina cost in order to attack
	if player.stamina < STRONG_ATTACK_STAMINA_COST / 2:
		finished.emit(IDLE)
		return
	player.change_stamina(-STRONG_ATTACK_STAMINA_COST) # expend the strong attack stamina cost
	player.attack_area_shape_2d.set_deferred("disabled", false)
	player.animation_player.play(ATTACKING_2.to_lower()) # play the strong attack animation


func physics_update(delta:float) -> void :
	state_timer += delta # count towards state_duration
	if state_timer > state_duration:
		finished.emit(IDLE)


func on_attack_area_area_entered(area:Area2D):
	player.attack_area_shape_2d.set_deferred("disabled", true)
	if area.has_method("take_damage"):
		area.take_damage(randi_range(MIN_ATTACK_DAMAGE, MAX_ATTACK_DAMAGE))


func on_attack_area_body_entered(body:Node2D):
	player.attack_area_shape_2d.set_deferred("disabled", true)
	if body.has_method("take_damage"):
		body.take_damage(randi_range(MIN_ATTACK_DAMAGE, MAX_ATTACK_DAMAGE))


func exit() -> void :
	# reset variables to default values
	player.attack_area_shape_2d.set_deferred("disabled", true)
	state_timer = 0.0
