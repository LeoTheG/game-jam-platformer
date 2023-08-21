extends Relic
var remainingJumps = 0
var maxJumps = 2

func handlePlayerEntered():
	Globals.Player.maxNumTimesJumpedInAir = 1
