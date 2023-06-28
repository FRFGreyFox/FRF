extends Area2D


@onready var collision = $CollisionPolygon2D

var damage: int = 1


func set_damage(new_damage: int):
	damage = new_damage
