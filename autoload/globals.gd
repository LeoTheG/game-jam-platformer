extends Node

var gunSoldier = load("res://characters/gun_soldier.tscn")

@onready var Root = get_node("/root/Game")
@onready var Player = Root.get_node("Player")
@onready var GameOverScreen = Root.get_node("GameOverScreen")
@onready var ReplayButton = GameOverScreen.get_node("ColorRect/VBoxContainer/Button")
@onready var GunSoldier = Root.get_node("GunSoldier")
@onready var Map: TileMap = Root.get_node("TileMap")


func _ready():
	GameOverScreen.hide()
	Player.connect("player_died", _on_Player_player_died)
	ReplayButton.connect("pressed", _on_ReplayButton_pressed)

	var outOfBoundTilePositions = Map.get_used_cells_by_id(0, 1, Vector2i(2, 0))

	for position in outOfBoundTilePositions:
		# modulate alpha to 0
		# Map.set_cell(0, position, 1, Vector2i(2, 0))
		# Map.set_cell(0, position, -1)
		pass


func _on_Player_player_died():
	resetGame()


func _on_ReplayButton_pressed():
	GameOverScreen.hide()


func resetGame():
	GameOverScreen.show()

	# restart player position, hp, etc
	Player.set_position(Vector2(5, -78))
	Player.animatedSprite2D.set_flip_h(false)
	Player.health = Player.MAX_HEALTH

	if GunSoldier == null:
		GunSoldier = gunSoldier.instantiate()

		GunSoldier.set_position(GunSoldier.INITIAL_POSITION)

		Root.add_child(GunSoldier)
