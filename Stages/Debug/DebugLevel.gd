extends BaseLevel


func _on_debug_hub_pc_use_zone_entered(who):
	if who is BaseHero:
		who.start_shooting()
		who.take_damage(40)
