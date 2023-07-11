extends Node2D

class_name BaseLevel

@onready var players = $Players
@onready var objects = $Objects
@onready var enemies = $NPCs/Enemies
@onready var allies = $NPCs/Allies
@onready var bullets = $Bullets
@onready var zones = $Zones
@onready var bg_music = $BackgroundMusic
@onready var canvas_color = $CanvasModulate

@export_category("Зависимости уровней")
@export var next_levels: Array[Resource]
@export_category("")

@export_category("Базовый уровень")

@export_group("Day Night")
@export var day_night_enabled: bool = false
@export var day_color: Color = Color("#ffffff")
@export var night_color: Color = Color("#091d3a")
@export_range(0.1, 1, 0.1) var time_scale: float = 0.1
var day_night_time: float = 0.0
@export_group("")

@export_group("Level end settings/Boss settings")
@export var is_boss_enabled: bool = false
@export var exist_boss: BaseBoss
@export_group("")

@export_group("Level end settings/Waves settings")
@export var is_waves_enabled: bool = false
@export_group("")

@export_group("Level end settings/Zones settings")
@export var is_level_target_zones_enabled: bool = false

@export_category("")


func _ready() -> void:
	gamestate.connect("connection_failed", _on_connection_failed)
	gamestate.connect("connection_succeeded", _on_connection_success)
	gamestate.connect("game_error", _on_game_error)


func _process(delta: float) -> void:
	if day_night_enabled:
		_day_night_proccess(delta)


func _day_night_proccess(delta: float) -> void:
	day_night_time += delta * time_scale
	canvas_color.color = night_color.lerp(day_color, abs(sin(day_night_time)))
	day_night_time = 0.0 if day_night_time >= PI else day_night_time


func set_day_night_enabled(enabled: bool = true) -> void:
	day_night_enabled = enabled


func _on_connection_failed() -> void:
	pass


func _on_connection_success() -> void:
	pass


func _on_game_error(what: String) -> void:
	pass


func get_players() -> Array:
	return players.get_children()


func spawn_player(new_player) -> void:
	var new_position = str(get_players().size())
	players.add_child(new_player)
	new_player.global_position = get_node("PlayersSpawnPoints/" + new_position).position


func get_objects() -> Array:
	return objects.get_children()


func spawn_object(new_object, object_position: Vector2) -> void:
	objects.add_child(new_object)
	new_object.position = object_position


func get_enemies() -> Array:
	return enemies.get_children()


func spawn_enemy(new_enemy: BasicEnemy, object_position: Vector2) -> void:
	enemies.add_child(new_enemy)
	new_enemy.position = object_position


func get_allies() -> Array:
	return allies.get_children()


func spawn_ally(new_ally, object_position: Vector2) -> void:
	allies.add_child(new_ally)
	new_ally.position = object_position


func get_bullets() -> Array:
	return bullets.get_children()


func spawn_bullet(new_bullet: BaseBullet) -> void:
	bullets.add_child(new_bullet)


func get_bg_music() -> AudioStreamPlayer:
	return bg_music


func get_zones():
	return zones.get_children()
