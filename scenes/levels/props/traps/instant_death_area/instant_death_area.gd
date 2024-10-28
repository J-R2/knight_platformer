extends Area2D

const DAMAGE_AMOUNT :float = 10000.0

func _ready() -> void :
	self.body_entered.connect(_on_body_entered)


func _on_body_entered(body:Node2D) -> void :
	if body.has_method("take_damage"):
		body.take_damage(DAMAGE_AMOUNT)
