extends CharacterBody2D

class_name BaseCharacter

signal current_hp_updated(damage: int)
signal max_hp_updated(new_max_hp: int)

const MAX_HP: int = 1000000
const MAX_ENERGY: int = 1000000
const MAX_SPEED: int = 1000

@export_category("Base Character")
@export_range(1, MAX_ENERGY, 1) var max_energy: int = 100
@export var weapon_resource: Resource
@export_group("movement")
@export var is_movable: bool = true
@export_range(1, MAX_SPEED, 1) var movement_speed: int = 100
@export_group("")
@export_group("vulnerability")
@export var is_vulnerable: bool = true
@export_range(1, MAX_HP, 1) var max_hp: int = 100
@export var hurt_box: HurtBox
@export var phisic_collision: CollisionShape2D
@export_group("")
@export_category("")

@onready var current_hp: int= max_hp
var puppet_current_hp: int = current_hp
var current_energy: int = max_energy
var is_alive: bool = true
var current_weapon: BaseWeapon


func _ready() -> void:
	if is_vulnerable:
		hurt_box.connect("hurt", take_damage)
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


@rpc("any_peer")
func set_current_hp(new_current_hp: int) -> void:
	puppet_current_hp = new_current_hp


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


@rpc("any_peer")
func _take_damage(damage: int) -> void:
	rpc("set_current_hp", current_hp - damage)


func take_damage(damage: int) -> void:
	if is_vulnerable:
		if is_multiplayer_authority():
			current_hp = current_hp - damage
			check_for_dying()
			rpc("set_current_hp", current_hp)
		else:
			current_hp = puppet_current_hp
		emit_signal("current_hp_updated", current_hp)


@rpc("call_local")
func _die():
	var ui = get_node("UI/IngameUI")
	if ui:
		ui.hide()
	if current_weapon:
		current_weapon.stop_shooting()
	if phisic_collision:
		phisic_collision.set_deferred("disabled", true)
	is_alive = false
	get_node("Sprite").hide()
	is_movable = false


func die():
	rpc("_die")


@rpc("any_peer")
func _hide():
	hide()


func hide():
	super.hide()
	rpc("_hide")


func check_for_dying() -> void:
	if is_vulnerable and is_alive and current_hp <= 0 and is_multiplayer_authority():
		rpc("_die")


func move_and_slide():
	if is_movable:
		super.move_and_slide()
