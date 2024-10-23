## Tracks the current state, changes the state, and calls the states functions.
class_name StateMachine
extends Node


@export var initial_state :State = null
var current_state :State = null
var previous_state :String = ""


func _ready() -> void:
	await owner.ready
	# set the initial state if not done in the inspector
	if initial_state == null:
		initial_state = get_child(0)
	current_state = initial_state
	previous_state = initial_state.name
	# connect to each state's finished signal
	for state_node : State in find_children("*", "State"):
		state_node.finished.connect(_on_state_finished)


func _process(delta: float) -> void:
	current_state.update(delta)


func _physics_process(delta: float) -> void:
	current_state.physics_update(delta)


func _unhandled_input(event: InputEvent) -> void:
	current_state.handle_input(event)


func _change_state(next_state :String) -> void :
	current_state.exit()
	previous_state = current_state.name
	current_state = get_node(next_state)
	current_state.enter()


func _on_state_finished(next_state :String) -> void :
	_change_state(next_state)
