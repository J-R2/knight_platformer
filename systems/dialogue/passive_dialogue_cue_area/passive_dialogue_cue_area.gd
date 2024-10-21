class_name PassiveDialogueCueArea
extends Area2D

@export var message = ""
@export_range(1.0, 5.0) var show_timer_length = 3.0
@onready var collisions :Array[CollisionShape2D] = [$CollisionShape2D, $CollisionShape2D2, $CollisionShape2D3, $CollisionShape2D4]
@onready var label: Label = $DialogueBubble/Label
@onready var dialogue_bubble: Sprite2D = $DialogueBubble



func _ready() -> void:
	label.text = message
	dialogue_bubble.hide()
	self.body_entered.connect(_on_body_entered)
	
	
	
func _on_body_entered(body:Node2D) -> void :
	dialogue_bubble.show()
	for collision in collisions:
		collision.disabled = true
	var timer = Timer.new()
	timer.wait_time = show_timer_length
	timer.one_shot = true
	self.add_child(timer)
	timer.start()
	timer.timeout.connect(_kill_self)


func _kill_self() -> void :
	var tween = create_tween()
	var duration :float = 0.25
	tween.tween_property(dialogue_bubble, "scale", Vector2.ZERO, duration)
	await tween.finished
	self.queue_free()
