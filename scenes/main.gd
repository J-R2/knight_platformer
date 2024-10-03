extends Node2D
# TODO fix the sliding bug and remove engine time scale line

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Engine.time_scale = 0.35 # for bug testing purpose


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
