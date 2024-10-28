extends Area2D

const DAMAGE_AMOUNT :float = 30.0
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
const IDLE_ANIMATION := "idle"
const ATTACK_ANIMATION := "attack"

func _ready() -> void :
	animated_sprite_2d.play(IDLE_ANIMATION)
	self.body_entered.connect(_on_body_entered)


func _on_body_entered(body:Node2D) -> void:
	if body is Player:
		animated_sprite_2d.play(ATTACK_ANIMATION)
		await animated_sprite_2d.animation_finished
		body.take_damage(DAMAGE_AMOUNT)
		_kill_self()
		

func _kill_self() -> void :
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 0, .2)
	tween.tween_callback(self.queue_free)
