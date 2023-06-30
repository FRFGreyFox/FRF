extends CharacterBody2D

@export_group("player_properties")
@export var weapon_resource: Resource
@export var base_movement_speed = 200
@export var max_hp = 50
@export var player_id := 1 :
	set(id):
		player_id = id

@onready var sprite = $Sprite
@onready var health_bar = $HealthBar
@onready var ingame_menu = $IngameMainMenu
@onready var endgame_menu = $EndGameMenu

@onready var current_movement_speed = base_movement_speed

var puppet_pos = Vector2()
var puppet_motion = Vector2()
var hp = 50
var current_weapon: Base_Weapon
var angle: float
var puppet_angle : float
var is_alive: bool = true


func _ready():
	current_weapon = weapon_resource.instantiate()
	add_child(current_weapon)
	if player_id == multiplayer.get_unique_id():
		$Camera2D.make_current()
	gamestate.current_world_scene.connect("game_ended", _end_game)


func set_player_id(id: int):
	player_id = id


func set_new_weapon(new_weapon: Base_Weapon):
	current_weapon.queue_free()
	current_weapon = new_weapon


@rpc
func _update_state(p_pos, p_motion):
	puppet_pos = p_pos
	puppet_motion = p_motion


@rpc
func _update_angle(new_angle):
	puppet_angle = new_angle


func _physics_process(_delta):
	if is_alive:
		_new_movement()
		_new_angle()


func _process(delta):
	if is_multiplayer_authority():
		if Input.is_action_just_pressed("ingame_menu"):
			if ingame_menu.visible:
				ingame_menu.hide()
			else:
				ingame_menu.show()


func _new_angle():
	"""Расчет угла поворота персонажа. Угол вычесляется на основе позиции мышки игрока."""
	if is_multiplayer_authority():
		angle = global_position.direction_to(get_global_mouse_position()).angle()
		rpc("_update_angle", angle)
	else:
		angle = puppet_angle


func _new_movement():
	var motion = Vector2()

	if is_multiplayer_authority():
		if Input.is_action_pressed("move_left"):
			motion += Vector2(-1, 0)
			sprite.flip_h = true
		if Input.is_action_pressed("move_right"):
			motion += Vector2(1, 0)
			sprite.flip_h = false
		if Input.is_action_pressed("move_up"):
			motion += Vector2(0, -1)
		if Input.is_action_pressed("move_down"):
			motion += Vector2(0, 1)
		rpc("_update_state", position, motion)
	else:
		position = puppet_pos
		motion = puppet_motion

	var animation: AnimationPlayer = get_node("Animation")
	if motion.x != 0 or motion.y != 0:
		animation.play("walk")
		animation.set_speed_scale((current_movement_speed / base_movement_speed) + (float(current_movement_speed % base_movement_speed) / base_movement_speed))
	else:
		animation.stop()

	# FIXME: Use move_and_slide
	set_velocity(motion * current_movement_speed)
	move_and_slide()
	if not is_multiplayer_authority():
		puppet_pos = position # To avoid jitter


func _on_hurt_box_hurt(damage: int):
	if is_alive and is_multiplayer_authority():
		rpc("get_damage", damage)


@rpc("call_local")
func get_damage(damage: int):
	"""Обработчик получения урона. Вызывается локально и глобально, что-бы данные о hp были консистенты везде."""
	hp -= damage
	if hp <= 0 and is_multiplayer_authority():
		rpc("die")
		return
	health_bar.update_health_bar(hp)


@rpc("call_local")
func die():
	"""
	Обработчик смерти игрока.
	 Вызывается локально и глобально, что-бы все клиенты получили инфу о смерти определенного игрока.
	"""
	is_alive = false
	
	# Останавливаем атоатаку.
	current_weapon.stop_shooting()
	
	# TODO: прятать все что связано с игроком
	# в идеале дать возможность переключать камеру на других игроков
	sprite.hide()
	health_bar.hide()
	$player_name_label.hide()


func set_player_name(new_name: String):
	get_node("player_name_label").set_text(new_name)


func _end_game(is_loose: bool):
	endgame_menu.show()
 

@rpc
func player_exited():
	"""
	Обработчки выхода игрока.
	 Вызывается только на других клиентах, т.к. локально игра сбрасывает всё состояние.
	"""
	# Сообщаем миру игры который игрок вышел.
	gamestate.current_world_scene.player_exited(self)
	
	# Удаляем игрока.
	queue_free()


func _on_ingame_main_menu_exit_pressed():
	"""Ловит нажатие игроком любую из кнопок выхода для дальнейшей обработки на сервере и клиентах."""
	# Сообщаем остальным что игрок вышел.
	rpc("player_exited")
	
	# Отключаем от сервера
	multiplayer.set_multiplayer_peer(null)
	
	# Грузим главное меню, очищаем ссостояние игры.
	var main_menu = load("res://Levels/Menues/MainMenu.tscn").instantiate()
	get_tree().get_root().add_child(main_menu)
	gamestate.current_world_scene.queue_free()
