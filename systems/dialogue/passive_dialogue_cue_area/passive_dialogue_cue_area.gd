class_name PassiveDialogueCueArea
extends Area2D


@onready var control: Control = $CanvasLayer/Control
@onready var dialogue_bubble_sprite: Sprite2D = $CanvasLayer/Control/DialogueBubbleSprite
@export var message = ""
@onready var rich_text_label: RichTextLabel = $CanvasLayer/Control/DialogueBubbleSprite/RichTextLabel


const TOP_LEFT = Vector2(60, 60)
const TOP_RIGHT = Vector2(580, 60)
const BOTTOM_LEFT = Vector2(60, 200)
const BOTTOM_RIGHT = Vector2(580, 200)
const POSITIONS = [TOP_LEFT, TOP_RIGHT, BOTTOM_LEFT, BOTTOM_RIGHT]
@export_enum("TOP_LEFT", "TOP_RIGHT", "BOTTOM_LEFT", "BOTTOM_RIGHT") var dialogue_bubble_position = 0
@export_range(1.0, 5.0) var show_timer_length = 3.0

func _ready() -> void:
	dialogue_bubble_sprite.position = POSITIONS[dialogue_bubble_position]
	rich_text_label.text = message
	control.hide()
	self.body_entered.connect(_on_body_entered)
	
	
	
func _on_body_entered(body:Node2D) -> void :
	control.show()
	var collision_shape_2d: CollisionShape2D = $CollisionShape2D
	collision_shape_2d.disabled = true
	var timer = Timer.new()
	timer.wait_time = show_timer_length
	timer.one_shot = true
	self.add_child(timer)
	timer.start()
	timer.timeout.connect(_kill_self)


func _kill_self() -> void :
	print("died")
	var tween = create_tween()
	var duration :float = 0.25
	tween.tween_property(dialogue_bubble_sprite, "scale", Vector2.ZERO, duration)
	await tween.finished
	self.queue_free()
