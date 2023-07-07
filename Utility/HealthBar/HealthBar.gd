extends Control

@export var color = Color(0, 187, 0)

@onready var bar: ProgressBar = $ProgressBar


func _ready() -> void:
	get_parent().get_parent().connect("current_hp_updated", update_health_bar)
	get_parent().get_parent().connect("max_hp_updated", set_max_value)


func set_new_stylebox(new_stylebox: StyleBoxFlat) -> void:
	bar.add_theme_stylebox_override("fill", new_stylebox)


@rpc("call_local")
func _set_max_value(max_value: int) -> void:
	bar.max_value = max_value


func set_max_value(max_value: int) -> void:
	rpc("_set_max_value", max_value)


@rpc("call_local")
func _update_health_bar(new_current_value: int) -> void:
	bar.value = new_current_value


func update_health_bar(currennt_health: int) -> void:
	rpc("_update_health_bar", currennt_health)
