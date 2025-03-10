extends Area2D

@export var damage_amount = 25 ## the amount of damage this trap does to an actor

var _is_active :bool = true ## fast moving traps can do damage each frame, this pauses damage temporarily

const _ATTACK_COOLDOWN_WAIT_TIME = .6 ## how long between damage registering

func _ready() -> void :
	self.body_entered.connect(_on_body_entered)
	

func _on_body_entered(body:Node2D) -> void :
	if body.has_method("take_damage") and _is_active:
		_is_active = false
		body.take_damage(damage_amount)
		#TODO don't know why i always make timers in code, this seems a good place to use one in scene tree
		var wait_timer = Timer.new()
		wait_timer.wait_time = _ATTACK_COOLDOWN_WAIT_TIME
		wait_timer.one_shot = true
		self.add_child(wait_timer)
		wait_timer.start()
		wait_timer.timeout.connect(func()->void:
			wait_timer.queue_free()
			_is_active = true
		)
