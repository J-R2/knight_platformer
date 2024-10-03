class_name PlayerState
extends State

const IDLE := "Idle"
const RUNNING := "Running"
const JUMPING := "Jumping"
const FALLING := "Falling"


var player :Player = null


func _ready() -> void:
	await owner.ready
	player = owner as Player
	assert(player is Player, "This actor is not a Player and cannot contain PlayerState(s).")
