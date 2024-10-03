class_name PlayerState
extends State


# The player states as String constants
const IDLE := "Idle"
const RUNNING := "Running"
const JUMPING := "Jumping"
const FALLING := "Falling"
const SLIDING := "Sliding"
const CROUCHING := "Crouching"

## a reference to the player
var player :Player = null


func _ready() -> void:
	await owner.ready # player is ready after the states are, must wait to get reference
	player = owner as Player
	# if player is not a player, print the error message
	assert(player is Player, "This actor is not a Player and cannot contain PlayerState(s).")
