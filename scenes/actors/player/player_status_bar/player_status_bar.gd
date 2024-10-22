extends Control

@onready var health_progress_bar: ProgressBar = $BarContainer/HealthBar/HealthProgressBar


func _ready() -> void :
	await owner.ready
	var player = get_tree().get_first_node_in_group("player")
	player.health_changed.connect(_on_player_health_changed)
	health_progress_bar.value = 100
	
	
func _on_player_health_changed(health:float) -> void:
	var tween = create_tween()
	tween.set_ease(Tween.EASE_IN)
	tween.set_trans(Tween.TRANS_SINE)
	tween.tween_property(health_progress_bar, "value", health, .5)
	tween.finished.connect(tween.kill)
	
