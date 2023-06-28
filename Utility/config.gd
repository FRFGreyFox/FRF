extends Node

var config_path = "res://config.cfg"
var config = ConfigFile.new()

var err = config.load(config_path)


func _ready():
	pass


func save_config(section: String, key: String, value):
	config.set_value(section, key, value)
	config.save(config_path)


func get_config(section: String, key: String):
	if err != OK:
		return
	return config.get_value(section, key, null)
