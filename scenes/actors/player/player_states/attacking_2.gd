extends PlayerState


var state_duration :float = 1.0 ## The length of the attack animation, RESET on state enter and animation has been set
var state_timer :float = 0.0 ## Counts up by delta, until reaches state_duration, then transition to next state
const STRONG_ATTACK_STAMINA_COST :float = 10.0 ## The stamina cost of a strong attack.

func _ready() -> void:
	super._ready()
	await owner.ready
	# NOTICE both attack states will probably run their _on_attack_area_entered() function, 
	# might need to change this to be in the state machine script to call only the current states _on_attack_area_entered function
	player.attack_area_2d.area_entered.connect(_on_attack_area_entered)
	state_duration = player.animation_player.get_animation(ATTACKING_2.to_lower()).length


func enter() -> void :
	# must have at least half of the strong attack stamina cost in order to attack
	if player.stamina < STRONG_ATTACK_STAMINA_COST / 2:
		finished.emit(IDLE)
		return
	player.change_stamina(-STRONG_ATTACK_STAMINA_COST) # expend the strong attack stamina cost
	player.attack_area_shape_2d.disabled = false # enable the attack area
	player.animation_player.play(ATTACKING_2.to_lower()) # play the strong attack animation



func physics_update(delta:float) -> void :
	state_timer += delta # count towards state_duration
	if state_timer > state_duration:
		finished.emit(IDLE)


#NOTICE read _ready function comments
func _on_attack_area_entered(area:Area2D):
	print("Attacking:  ", area.name)
	player.attack_area_shape_2d.disabled = true


func exit() -> void :
	# reset variables to default values
	player.attack_area_shape_2d.disabled = true
	state_timer = 0.0
