extends PlayerState


const JUMP_FORCE := 350.0

func _ready() -> void:
	super._ready()
	await owner.ready
	player.wall_climb_detector.area_entered.connect(_on_wall_climb_area_entered)

func enter() -> void :
	# play the jump animation
	player.animation_player.play(JUMPING.to_lower())
	# set the jumping collision size
	player.set_collision_shape()
	# add the jump force to the y velocity
	player.velocity.y += -JUMP_FORCE
	# move the player
	player.move_and_slide()
	player.wall_climb_detector_shape_2d.disabled = false
	
	
	
func physics_update(delta:float) -> void :
	player.set_collision_orientation()
	player.move_player(delta)
	# if player has startet going down change to falling state
	if player.velocity.y > 0.0:
		finished.emit(FALLING)


	
func _on_wall_climb_area_entered(area :Area2D):
	if area.is_in_group("wall_hanging_areas"):
		finished.emit(WALL_HANGING)
		print("test")



func exit() -> void :
	player.wall_climb_detector_shape_2d.disabled = true
