class_name Player
extends CharacterBody2D



const MAX_SPEED := 200.0


@export var speed := MAX_SPEED
const GRAVITY := 900.0 ## the gravity
const DEFAULT_COLLISION_SIZE = Vector2(18, 38) ## the default size of the collision_shape2d rectangle
const DEFAULT_COLLISION_POS = Vector2(-5, -19) ## the default position of the collision rectangle


var direction := Vector2.RIGHT ## keeps track of the players facing direction left or right, sign()ed

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D


#================================================================================
@onready var state_label: Label = $StateLabel
#================================================================================


func _ready() -> void:
	# set the collision shapes default values
	set_collision_shape()




func _physics_process(delta: float) -> void:
	# set the sprites orientation
	sprite_2d.flip_h = true if direction.x < 0 else false
#================================================================================
	state_label.text = get_node("StateMachine").current_state.name
#================================================================================



func set_collision_orientation(collision_position :Vector2 = DEFAULT_COLLISION_POS) -> void :
	collision_shape_2d.position.x = collision_position.x * direction.x


func set_collision_shape(collision_position :Vector2 = DEFAULT_COLLISION_POS, collision_size :Vector2 = DEFAULT_COLLISION_SIZE) -> void :
	collision_shape_2d.position = collision_position
	collision_shape_2d.shape.size = collision_size
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
