extends BaseCharacter

class_name BaseHero

@export var player_id := 1 :
	set(id):
		player_id = id

@onready var sprite = $Sprite
@onready var animation = $Animation
@onready var ui = $UI
@onready var health_bar = $UI/HealthBar
@onready var ingame_menu = $UI/IngameMainMenu
@onready var endgame_menu = $UI/EndGameMenu
@onready var player_name = $UI/PlayerNameLabel

var puppet_pos: Vector2 = Vector2()
var puppet_motion: Vector2 = Vector2()
var angle: float
var puppet_angle : float


func _ready() -> void:
	super._ready()
	if player_id == multiplayer.get_unique_id():
		$Camera2D.make_current()


func set_player_id(id: int) -> void:
	player_id = id


@rpc
func _update_state(p_pos: Vector2, p_motion: Vector2) -> void:
	puppet_pos = p_pos
	puppet_motion = p_motion


@rpc
func _update_angle(new_angle: float) -> void:
	puppet_angle = new_angle


func _physics_process(_delta: float) -> void:
	if is_alive:
		_new_movement()
		_new_angle()


func _process(delta: float) -> void:
	if is_multiplayer_authority():
		if Input.is_action_just_pressed("ingame_menu"):
			if ingame_menu.visible:
				ingame_menu.hide()
			else:
				ingame_menu.show()


func _new_angle() -> void:
	"""Расчет угла поворота персонажа. Угол вычесляется на основе позиции мышки игрока."""
	if is_multiplayer_authority():
		angle = global_position.direction_to(get_global_mouse_position()).angle()
		rpc("_update_angle", angle)
	else:
		angle = puppet_angle


func _new_movement() -> void:
	var motion = Vector2()

	if is_multiplayer_authority():
		InputMap
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
	else:
		animation.stop()

	# FIXME: Use move_and_slide
	set_velocity(motion * movement_speed)
	move_and_slide()
	if not is_multiplayer_authority():
		puppet_pos = position # To avoid jitter


func take_damage(damage: int) -> void:
	super.take_damage(damage)
	emit_signal("current_hp_updated", current_hp)


func set_player_name(new_name: String):
	player_name.set_text(new_name)
 

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
