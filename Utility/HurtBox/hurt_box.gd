extends Area2D

class_name HurtBox

signal hurt(damage)

@export var collision: CollisionShape2D
@onready var disable_timer = $disableTimer
@export_enum("Cooldown","HitOnce") var HurtBoxType = 1


func _on_area_entered(area):
	if area.is_in_group("attack") and not area.get("damage") == null:
		match HurtBoxType:
			0: #Cooldown
				collision.call_deferred("set","disabled",true)
				disable_timer.start()
			1: #HitOnce
				pass
		emit_signal("hurt", area.damage)


func _on_timer_timeout():
	collision.call_deferred("set","disabled",false)
