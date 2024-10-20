class_name Player
extends CharacterBody2D



const MAX_SPEED := 150.0
const DIALOGUE_ICON = preload("res://scenes/actors/player/art/icons/talk.png")

@export var speed := MAX_SPEED
const GRAVITY := 900.0 ## the gravity
const DEFAULT_COLLISION_POS := Vector2(-5, -19) ## the default position of the collision shape
const DEFAULT_COLLISION_SIZE := Vector2(18, 38) ##NOTICE deprecated
const DEFAULT_COLLISION_RADIUS :int = 8 ## the default size of the collision_shape2d
const DEFAULT_COLLISION_HEIGHT :int = 38 ## the default size of the collision_shape2d


var direction := Vector2.RIGHT ## keeps track of the players facing direction left or right, sign()ed

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D
@onready var wall_climb_detector: Area2D = $WallClimbDetector
@onready var wall_climb_detector_shape_2d: CollisionShape2D = $WallClimbDetector/WallClimbDetectorShape2D
@onready var attack_area_2d: Area2D = $AttackArea2D
@onready var attack_area_shape_2d: CollisionShape2D = $AttackArea2D/AttackAreaShape2D
@onready var interaction_area: Area2D = $InteractionArea
@onready var icon: Sprite2D = $Icon


var is_dialogue_interactable :bool = false
var is_interactable :bool = false


#================================================================================
@onready var state_label: Label = $StateLabel
#================================================================================


func _ready() -> void:
	# set the collision shapes default values
	set_collision_shape()
	icon.hide()
	interaction_area.area_entered.connect(_on_interaction_area_entered)
	interaction_area.area_exited.connect(_on_interaction_area_exited)



func _physics_process(delta: float) -> void:
	# set the sprites orientation
	sprite_2d.flip_h = true if direction.x < 0 else false
#================================================================================
	state_label.text = get_node("StateMachine").current_state.name
#================================================================================



func _on_interaction_area_entered(area:Area2D) -> void :
	is_interactable = true
	if area is DialogueInteractionArea:
		icon.texture = DIALOGUE_ICON
		icon.show()
		is_dialogue_interactable = true

func _on_interaction_area_exited(area:Area2D) -> void :
	is_interactable = false
	icon.hide()
	if area is DialogueInteractionArea:
		is_dialogue_interactable = false



func set_collision_orientation(collision_position :Vector2 = DEFAULT_COLLISION_POS) -> void :
	collision_shape_2d.position.x = collision_position.x * direction.x
	if direction.x == -1:
		wall_climb_detector_shape_2d.position.x = -2
		attack_area_shape_2d.position.x = -26
	else:
		wall_climb_detector_shape_2d.position.x = 2
		attack_area_shape_2d.position.x = 26


func set_collision_shape(collision_position :Vector2 = DEFAULT_COLLISION_POS, collision_radius :int = DEFAULT_COLLISION_RADIUS, collision_height :int = DEFAULT_COLLISION_HEIGHT):
	collision_shape_2d.position = collision_position
	collision_shape_2d.shape.radius = collision_radius
	collision_shape_2d.shape.height = collision_height
	set_collision_orientation(collision_position)

func move_player(delta:float) -> void :
	var move_direction := Vector2(Input.get_axis("move_left", "move_right"), 0)
	if move_direction.sign() != Vector2.ZERO:
		direction.x = move_direction.sign().x
	# add the gravity
	velocity.y += GRAVITY * delta
	# move the player
	velocity.x = move_direction.x * speed
	move_and_slide()
