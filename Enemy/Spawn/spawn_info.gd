extends Resource

class_name Spawn_info

# Объект врага
@export var enemy: Resource

# Сколько противников всего в волне.
@export var enemy_total_count: int = 100

# Задержка между спавном (в секундах)
@export var enemy_spawn_delay: float = 10

# Кол-во объектов за итерацию эскалирования
@export var enemy_count_escalating: int = 5

# Кол-во объектов при первой итерации
@export var enemy_first_wave_count: int = 10
