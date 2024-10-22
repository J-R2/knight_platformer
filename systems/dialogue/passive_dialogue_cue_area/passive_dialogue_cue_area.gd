## Displays a dialogue bubble to attract the player to a specific point.
class_name PassiveDialogueCueArea
extends Area2D

## The message displayed in the dialogue bubble. MUST BE SHORT!
@export var message = ""
## The amount of time that the dialogue bubble is displayed for.
@export_range(1.0, 5.0) var show_timer_length = 3.0
## The activation area CollisionShapes.
@onready var collisions :Array[CollisionShape2D] = [$CollisionShape2D, $CollisionShape2D2, $CollisionShape2D3, $CollisionShape2D4]
## The label to hold the message text.
@onready var label: Label = $DialogueBubble/Label
## The dialogue bubble Sprite2D.
@onready var dialogue_bubble: Sprite2D = $DialogueBubble


# Set the label text to the message, default hide the bubble sprite, and connect the signal to activate.
func _ready() -> void:
	show()
	label.text = message
	dialogue_bubble.hide()
	self.body_entered.connect(_on_body_entered)
	
	
# Show the dialogue bubble and start the timer until queue_free()
func _on_body_entered(body:Node2D) -> void :
	dialogue_bubble.show()
	for collision in collisions: # Disable the activator collision shapes. Possible to reset timer otherwise.
		collision.set_deferred("disabled", true)
	var timer = Timer.new()
	timer.wait_time = show_timer_length
	timer.one_shot = true
	self.add_child(timer)
	timer.start()
	timer.timeout.connect(_kill_self)


# Shrink the dialogue bubble into oblivion.
func _kill_self() -> void :
	var tween = create_tween()
	var duration :float = 0.25
	tween.tween_property(dialogue_bubble, "scale", Vector2.ZERO, duration)
	await tween.finished
	self.queue_free()
