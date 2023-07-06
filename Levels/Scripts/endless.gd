extends Node2D

@export var current_wave_id: int = 0

@onready var waves_node = $Waves
@onready var enemies = $Enemies
@onready var players = $Players
@onready var players_bullets = $PlayersBullets

var current_wave: BaseWave

signal game_ended(is_loose)


func _run_current_wave():
	current_wave = waves_node.get_child(current_wave_id)
	current_wave.run()


func _update_current_wave_index():
	current_wave_id += 1


func _on_first_wave_timer_timeout():
	_run_current_wave()


func _on_waves_timer_timeout():
	"""Через равный промежуток времени запускает следующую волну."""
	_update_current_wave_index()
	_run_current_wave()


func _on_players_life_check_timer_timeout():
	# TODO: необходимо отвязаться от таймера, и проверять кол-во игроков оставшихся по мере их смерти.
	var died_players_counter = 0
	var players_ = players.get_children()
	for player in players_:
		if not player.is_alive:
			died_players_counter += 1
	if players_.size() == died_players_counter:
		emit_signal("game_ended", true)


@rpc("call_local")
func update_enemies_target_player(new_enemy_target_player: CharacterBody2D, exited_player: CharacterBody2D):
	for enemy in enemies.get_children():
		# Проверяем что переназначаем только тех врагов, у которых игрок вышел.
		if enemy.target_player == exited_player:
			enemy.update_target_player(new_enemy_target_player)


func player_exited(exited_player: CharacterBody2D):
	"""
	Обработчик отвчающий за логику всего игрового мира в момент выхода игрока из игры.
	 Необходимо вызывать при выходе игрока из игры.
	 Задача функции очистить, переназначить или уничтожить всё, что было связанно с вышедшем игроком.
	"""
	# Очистку производим на сервере, а затем синхронизируем результат с остальными клиентами,
	# что-бы не произошло конфликтов.
	if multiplayer.is_server():
		var new_enemy_target_player
		for player in players.get_children():
			if player != exited_player:
				# TODO: Пока берем первого попавшегося игрока. Далее необходимо будет оставшихся врагов переназначить случайным образом.
				new_enemy_target_player = player
				break
		# Отправляем клиентам (+ запускаем локально) новую информацию для врагов.
		rpc("update_enemies_target_player", new_enemy_target_player, exited_player)
