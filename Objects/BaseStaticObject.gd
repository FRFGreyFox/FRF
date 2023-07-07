extends StaticBody2D

class_name BaseStaticObject

signal use_zone_entered(who: Node2D)

@export_category("Базовый статичный объект")
@export_group("Уязвимость")
@export var is_destroyable: bool = false
@export_range(1, 10000, 1) var max_hp: int = 100
@export var hurt_box: HurtBox
@export_group("")

@export_group("Использование")
@export var is_usable: bool = false
@export var use_box: UseBox
@export_group("")
@export_category("")

var current_hp = max_hp


func _ready() -> void:
	if is_usable and use_box:
		use_box.connect("entered", _object_entered_use_zone)
	if is_destroyable and hurt_box:
		hurt_box.connect("hurt", take_damage)


func _object_entered_use_zone(who: Node2D) -> void:
	emit_signal("use_zone_entered", who)
	print_debug(who, " intered in use zone of ", name)


@rpc("call_local")
func set_current_hp(new_hp: int) -> void:
	current_hp = new_hp


func take_damage(damage: int) -> void:
	print_debug(damage)
	if is_destroyable:
		if current_hp - damage > 0:
			rpc("set_current_hp", current_hp - damage)
		else:
			rpc("destroy")


@rpc("call_local")
func destroy() -> void:
	queue_free()


@rpc("call_local")
func _update_position(new_position: Vector2) -> void:
	position = new_position


func move_to(new_position: Vector2) -> void:
	rpc("_update_position", new_position)
