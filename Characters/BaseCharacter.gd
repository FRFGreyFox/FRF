extends CharacterBody2D

class_name BaseCharacter

signal current_hp_updated(damage: int)
signal max_hp_updated(new_max_hp: int)

const MAX_HP: int = 1000000
const MAX_ENERGY: int = 1000000
const MAX_SPEED: int = 1000

@export var is_vulnerable: bool = true
@export var is_movable: bool = true
@export_range(1, MAX_HP, 1) var max_hp: int = 100
@export_range(1, MAX_ENERGY, 1) var max_energy: int = 100
@export_range(1, MAX_SPEED, 1) var movement_speed: int = 100
@export var weapon_resource: Resource

var current_hp: int= max_hp
var current_energy: int = max_energy
var is_alive: bool = true
var current_weapon: BaseWeapon


func _ready() -> void:
	if weapon_resource:
		current_weapon = weapon_resource.instantiate()
		current_weapon.set_name("Weapon")
		add_child(current_weapon)
	current_weapon.stop_shooting()
	emit_signal("max_hp_updated", max_hp)
	emit_signal("current_hp_updated", current_hp)


func stop_shooting() -> void:
	current_weapon.stop_shooting()


func start_shooting() -> void:
	current_weapon.start_shooting()


func set_new_weapon(new_weapon: BaseWeapon) -> void:
	current_weapon.queue_free()
	current_weapon = new_weapon


@rpc("call_local")
func set_max_hp(new_max_hp: int) -> void:
	if new_max_hp < 1:
		max_hp = 1
	else:
		max_hp = new_max_hp
	emit_signal("max_hp_updated", max_hp)


@rpc("call_local")
func set_current_hp(new_current_hp: int) -> void:
	current_hp = new_current_hp
	emit_signal("current_hp_updated", current_hp)


func add_max_hp(add_hp: int) -> void:
	if max_hp + add_hp > MAX_HP:
		rpc("set_max_hp", MAX_HP)
	else:
		rpc("set_max_hp", max_hp + add_hp)


func sub_max_hp(sub_hp: int) -> void:
	if max_hp - sub_hp < 1:
		rpc("set_max_hp", 1)
	else:
		rpc("set_max_hp", max_hp - sub_hp)
	if current_hp > max_hp:
		rpc("set_current_hp", max_hp)


func check_livenes() -> bool:
	if is_vulnerable:
		return current_hp > 0
	return true


@rpc("call_local")
func _take_damage(damage: int) -> void:
	if is_vulnerable:
		set_current_hp(current_hp - damage)


func take_damage(damage: int) -> void:
	if is_vulnerable:
		rpc("_take_damage", damage)
	check_for_dying()


@rpc("call_local")
func _die() -> void:
	var ui = get_node("UI")
	if ui:
		ui.hide()
	if current_weapon:
		current_weapon.stop_shooting()
	is_alive = false
	hide()
	is_movable = false


func die():
	rpc("die")


@rpc("any_peer")
func _hide():
	hide()


func hide():
	super.hide()
	rpc("_hide")


func check_for_dying() -> void:
	if is_vulnerable and is_alive and current_hp <= 0:
		rpc("die")


func move_and_slide():
	if is_movable:
		super.move_and_slide()
