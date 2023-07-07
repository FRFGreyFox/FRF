extends Area2D

class_name UseBox

signal entered(who: Node2D)


func _on_body_entered(body: Node2D) -> void:
	if body != get_parent():
		emit_signal("entered", body)
