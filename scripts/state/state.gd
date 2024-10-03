## Abstract state definition.  All ActorStates must extend State to ensure all states have the same methods.
class_name State
extends Node

signal finished(next_state :String)

func enter() -> void :
	pass


func exit() -> void :
	pass


func handle_input(event :InputEvent) -> void :
	pass


func update(delta :float) -> void :
	pass


func physics_update(delta :float) -> void :
	pass
