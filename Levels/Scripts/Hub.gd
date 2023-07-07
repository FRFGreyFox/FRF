extends BaseLevel


func _on_host_area_body_entered(body):
	pass


func _on_debug_hub_pc_use_zone_entered(who):
	if who is BaseHero:
		who.start_shooting()
