extends Relic

func handlePlayerEntered():
	Globals.Player.heal(+50)
	Globals.Player.get_node("InvincibilityTimer").set_wait_time(2)
