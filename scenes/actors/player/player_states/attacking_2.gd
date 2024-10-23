extends PlayerState

var state_duration :float = 1.0
var state_timer :float = 0.0
const STRONG_ATTACK_STAMINA_COST :float = 10.0

func _ready() -> void:
	super._ready()
	await owner.ready
	player.attack_area_2d.area_entered.connect(_on_attack_area_entered)


func enter() -> void :
	if player.stamina < STRONG_ATTACK_STAMINA_COST / 2:
		finished.emit(IDLE)
		return
	player.change_stamina(-STRONG_ATTACK_STAMINA_COST)
	player.attack_area_shape_2d.disabled = false
	player.animation_player.play(ATTACKING_2.to_lower())
	state_duration = player.animation_player.current_animation_length



func physics_update(delta:float) -> void :
	state_timer += delta
	if state_timer > state_duration:
		finished.emit(IDLE)


func _on_attack_area_entered(area:Area2D):
	print("Attacking:  ", area.name)
	player.attack_area_shape_2d.disabled = true

func exit() -> void :
	player.attack_area_shape_2d.disabled = true
	state_timer = 0.0
