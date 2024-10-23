extends Control

@onready var health_progress_bar: ProgressBar = %HealthProgressBar
@onready var stamina_progress_bar: ProgressBar = %StaminaProgressBar

const FADE_DURATION :float = 0.3
var _fade_timer :Timer


func _ready() -> void :
	await owner.ready
	var player :Player = get_tree().get_first_node_in_group("player")
	player.health_changed.connect(_on_player_health_changed)
	health_progress_bar.max_value = player.MAX_HEALTH
	health_progress_bar.value = player.MAX_HEALTH
	player.stamina_changed.connect(_on_player_stamina_changed)
	stamina_progress_bar.max_value = player.MAX_STAMINA
	stamina_progress_bar.value = player.MAX_STAMINA
	_fade_timer = Timer.new()
	_fade_timer.one_shot = true
	self.add_child(_fade_timer)
	_fade_timer.timeout.connect(fade_out)
	fade_in()
	

func _on_player_stamina_changed(stamina:float) -> void :
	fade_in()
	var duration :float = 0.5
	var difference = abs(stamina - stamina_progress_bar.value)
	if difference < 1.5:
		duration = get_process_delta_time()
	var tween = create_tween()
	tween.tween_property(stamina_progress_bar, "value", stamina, duration)


func _on_player_health_changed(health:float) -> void:
	fade_in()
	var tween = create_tween()
	tween.set_ease(Tween.EASE_IN)
	tween.set_trans(Tween.TRANS_SINE)
	tween.tween_property(health_progress_bar, "value", health, .5)



func fade_in() -> void :
	_reset_fade_timer()
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 1, FADE_DURATION)



func fade_out() -> void :
	if health_progress_bar.value < health_progress_bar.max_value:
		return
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 0, FADE_DURATION)


func _reset_fade_timer() -> void :
	_fade_timer.wait_time = 5.0
	_fade_timer.start()
	
