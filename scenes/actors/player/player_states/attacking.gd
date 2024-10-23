extends PlayerState

var state_duration :float = 1.0 # RESET ON _READY(), after setting animation, get the length of the attack animation.
var state_timer :float = 0.0 # Counts up by delta, until reaches state_duration, then transition to next state
var next_state := IDLE # default next state to IDLE

const ATTACK_STAMINA_COST :float = 7.0

func _ready() -> void:
	super._ready()
	await owner.ready
	player.attack_area_2d.area_entered.connect(_on_attack_area_entered)


func enter() -> void :
	if player.stamina < ATTACK_STAMINA_COST / 2:
		finished.emit(IDLE)
		return
	player.change_stamina(-ATTACK_STAMINA_COST)
	player.attack_area_shape_2d.disabled = false
	player.animation_player.play(ATTACKING.to_lower())
	state_duration = player.animation_player.current_animation_length


func physics_update(delta:float) -> void :
	state_timer += delta
	if Input.is_action_just_pressed("attack"):
		next_state = ATTACKING_2
	if state_timer > state_duration:
		finished.emit(next_state)


func _on_attack_area_entered(area:Area2D):
	print("Attacking:  ", area.name)
	player.attack_area_shape_2d.disabled = true


func exit() -> void :
	next_state = IDLE
	player.attack_area_shape_2d.disabled = true
	state_timer = 0.0
