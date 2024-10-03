class_name Player
extends CharacterBody2D

@export var acceleration := 1200.0
@export var deceleration := 3000.0
@export var speed := 600.0
@export var jump_force := 600.0
const MAX_SPEED := 300.0
const GRAVITY := 980.0

var direction := Vector2.ZERO

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D
