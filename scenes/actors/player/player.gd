class_name Player
extends CharacterBody2D


@export var speed := 250.0
const MAX_SPEED := 300.0
const GRAVITY := 980.0
const DEFAULT_COLLISION_SIZE = Vector2(18, 38)
const DEFAULT_COLLISION_POS = Vector2(-5, -19)


var direction := Vector2.ZERO

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D

func _ready() -> void:
	collision_shape_2d.position = DEFAULT_COLLISION_POS
	collision_shape_2d.shape.size = DEFAULT_COLLISION_SIZE

func _physics_process(delta: float) -> void:
	if direction.x == -1:
		sprite_2d.flip_h = true
	else:
		sprite_2d.flip_h = false
