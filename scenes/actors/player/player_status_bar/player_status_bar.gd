extends Control

@onready var health_progress_bar: ProgressBar = $BarContainer/HealthBar/HealthProgressBar
const FADE_DURATION :float = 0.3

var _fade_timer :Timer


func _ready() -> void :
	await owner.ready
	var player = get_tree().get_first_node_in_group("player")
	player.health_changed.connect(_on_player_health_changed)
	health_progress_bar.value = 100
	_fade_timer = Timer.new()
	_fade_timer.one_shot = true
	self.add_child(_fade_timer)
	_fade_timer.timeout.connect(_fade_out)
	_fade_in()
	
func _on_player_health_changed(health:float) -> void:
	_fade_in()
	var tween = create_tween()
	tween.set_ease(Tween.EASE_IN)
	tween.set_trans(Tween.TRANS_SINE)
	tween.tween_property(health_progress_bar, "value", health, .5)
	tween.finished.connect(tween.kill)
	

func _fade_in() -> void :
	_reset_fade_timer()
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 1, FADE_DURATION)
	tween.finished.connect(tween.kill)
	

func _fade_out() -> void :
	if health_progress_bar.value < health_progress_bar.max_value:
		return
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 0, FADE_DURATION)
	tween.finished.connect(tween.kill)
	

func _reset_fade_timer() -> void :
	_fade_timer.wait_time = 5.0
	_fade_timer.start()
	
