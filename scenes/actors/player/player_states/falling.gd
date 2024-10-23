extends PlayerState

var next_state := IDLE


func _ready() -> void:
	super._ready()
	await owner.ready
	player.wall_climb_detector.area_entered.connect(_on_wall_climb_area_entered)


func enter() -> void :
	# play the falling animation and set the collision size
	player.animation_player.play(FALLING.to_lower())
	player.set_collision_shape()
	next_state = IDLE
	player.wall_climb_detector_shape_2d.disabled = false # enable wall grabbing ability


func physics_update(delta :float) -> void :
	# set the collision orientation, in physics since you can turn while mid-air
	player.set_collision_orientation()
	player.move_player(delta) # player can move while falling
	# transition to crouch or roll if pressed while falling
	if Input.is_action_just_pressed("crouch"):
		next_state = SLIDING
	if Input.is_action_just_pressed("roll"):
		next_state = ROLLING
	# transition to next state when on floor
	if player.is_on_floor():
		finished.emit(next_state)


## hang on the wall if you touch a wall_climb area while falling
func _on_wall_climb_area_entered(area :Area2D):
	if player.player_state_machine.current_state.name == FALLING:
		print("hello from falling")
		if area.is_in_group("wall_hanging_areas"):
			finished.emit(WALL_HANGING)


func exit() -> void :
	# disable wall climbing ability
	player.wall_climb_detector_shape_2d.disabled = true
