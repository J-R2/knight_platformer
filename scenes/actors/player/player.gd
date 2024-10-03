class_name Player
extends CharacterBody2D


@export var speed := 250.0 ## the player's speed
const MAX_SPEED := 300.0 ## the max speed (not used)
const GRAVITY := 980.0 ## the gravity
const DEFAULT_COLLISION_SIZE = Vector2(18, 38) ## the default size of the collision_shape2d rectangle
const DEFAULT_COLLISION_POS = Vector2(-5, -19) ## the default position of the collision rectangle


var direction := Vector2.ZERO ## keeps track of the players facing direction left or right, sign()ed

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D


func _ready() -> void:
	# set the collision shapes default values
	collision_shape_2d.position = DEFAULT_COLLISION_POS
	collision_shape_2d.shape.size = DEFAULT_COLLISION_SIZE



func _physics_process(delta: float) -> void:
	# set the sprites orientation
	if direction.x == -1:
		sprite_2d.flip_h = true
	else:
		sprite_2d.flip_h = false
