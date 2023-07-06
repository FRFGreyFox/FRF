extends StaticBody2D

class_name BaseStaticObject

@export var is_usable: bool = false
@export var is_destroyable: bool = false
@export_range(1, 10000, 1) var max_hp: int = 100

var current_hp = max_hp


func take_damage(damage: int) -> void:
	if is_destroyable:
		current_hp -= damage
		if current_hp <= 0:
			destroy()


func destroy() -> void:
	queue_free()
