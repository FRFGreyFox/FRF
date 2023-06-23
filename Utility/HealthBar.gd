extends Control

@export var color = Color(0, 187, 0)

@onready var bar: ProgressBar = $ProgressBar

func _ready():
	bar.max_value = self.get_parent().max_hp

func set_fill_color(color: Color):
	bar.get_theme_stylebox("fill").bg_color = color

func set_max_value(max_value):
	bar.max_value = max_value

func update_health_bar(currennt_health):
	bar.value = currennt_health
