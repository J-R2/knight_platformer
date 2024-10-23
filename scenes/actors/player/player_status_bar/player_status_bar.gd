extends Control

@onready var health_progress_bar: ProgressBar = %HealthProgressBar
@onready var stamina_progress_bar: ProgressBar = %StaminaProgressBar

const FADE_DURATION :float = 0.8  ## how long it takes the hud to fade in / out
const DYNAMIC_FADE_WAIT_TIME = 3.5 ## how long to wait in order to fade out
var _fade_timer :Timer ## the timer to dynamically fade out if stats are full
var player :Player = null

func _ready() -> void :
	await owner.ready
	player = get_tree().get_first_node_in_group("player")
	# connect to health signal and set the progress bar values
	player.health_changed.connect(_on_player_health_changed)
	health_progress_bar.max_value = player.MAX_HEALTH
	health_progress_bar.value = player.MAX_HEALTH
	# connect to staminal signal and set the progress bar values
	player.stamina_changed.connect(_on_player_stamina_changed)
	stamina_progress_bar.max_value = player.MAX_STAMINA
	stamina_progress_bar.value = player.MAX_STAMINA
	# create a dynamic fade timer and connect fade_out method
	_fade_timer = Timer.new()
	_fade_timer.one_shot = true
	self.add_child(_fade_timer)
	_fade_timer.timeout.connect(fade_out)
	

## Changes the stamina status bar to match the new stamina value.
func _on_player_stamina_changed(stamina:float) -> void :
	fade_in()
	var difference = abs(stamina - stamina_progress_bar.value)
	if difference < 1.5:
		stamina_progress_bar.value = stamina
	else :
		var tween = create_tween()
		tween.tween_property(stamina_progress_bar, "value", stamina, 0.5)


## Changes the health status bar to match the new stamina value.
func _on_player_health_changed(health:float) -> void:
	fade_in()
	var difference = abs(health - health_progress_bar.value)
	if difference < 1.5:
		health_progress_bar.value = health
	else :
		var tween = create_tween()
		tween.tween_property(health_progress_bar, "value", health, 0.5)


## Fades the status bars in.
func fade_in() -> void :
	_reset_fade_timer()
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 1, FADE_DURATION)


## Fade out the status bar.
func fade_out() -> void :
	if player.has_max_stats():
		var tween = create_tween()
		tween.tween_property(self, "modulate:a", 0, FADE_DURATION)


## Restarts the countdown until the hud should fade out.
func _reset_fade_timer() -> void :
	_fade_timer.wait_time = DYNAMIC_FADE_WAIT_TIME
	_fade_timer.start()
	
