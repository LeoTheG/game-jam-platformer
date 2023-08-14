extends Node

var gunSoldier = load("res://characters/gun_soldier.tscn")
var meleeSoldier = load("res://characters/melee_soldier.tscn")

@onready var Root = get_node("/root/Game")
@onready var Player = Root.get_node("Player")
@onready var GameOverScreen = Root.get_node("GameOverScreen")
@onready var ReplayButton = GameOverScreen.get_node("ColorRect/VBoxContainer/Button")
@onready var Enemies = Root.get_node("TileMap/Enemies")
#@onready var GunSoldier = Root.get_node("GunSoldier")
#@onready var MeleeSoldier = Root.get_node("MeleeSoldier")
var initialEnemyPositions = [] 
@onready var Map: TileMap = Root.get_node("TileMap")


func getEnemyPositions():
	var enemies = Enemies.get_children()
	for enemy in enemies:
		var className = enemy.enemyName
		var position = enemy.get_position()
		var enemyObj = {
			"className": className,
			"position": position
		}
		initialEnemyPositions.append(enemyObj)
	
func _ready():
	GameOverScreen.hide()
	Player.connect("player_died", _on_Player_player_died)
	ReplayButton.connect("pressed", _on_ReplayButton_pressed)
	getEnemyPositions()

	var outOfBoundTilePositions = Map.get_used_cells_by_id(0, 1, Vector2i(2, 0))

	for position in outOfBoundTilePositions:
		# modulate alpha to 0
		# Map.set_cell(0, position, 1, Vector2i(2, 0))
		# Map.set_cell(0, position, -1)
		pass


func _on_Player_player_died():
	GameOverScreen.show()
	#resetGame()
	pass


func _on_ReplayButton_pressed():
	GameOverScreen.hide()
	resetGame()
	print("emitted player died")


func resetGame():

	# restart player position, hp, etc
	Player.set_position(Vector2(-55, -74))
	Player.animatedSprite2D.set_flip_h(false)
	Player.health = Player.MAX_HEALTH
	Player.isAlive = true
	
	
	var enemies = Enemies.get_children()
	for enemy in enemies:
		enemy.queue_free()
	
	print(initialEnemyPositions)
	
	for position in initialEnemyPositions:
		if position.className == "GunSoldier":
			var enemy = gunSoldier.instantiate()
			Enemies.add_child(enemy)
			enemy.position = position.position
		if position.className == "MeleeSoldier":
			var enemy = meleeSoldier.instantiate()
			Enemies.add_child(enemy)
			enemy.position = position.position


	"""if GunSoldier == null:
		GunSoldier = gunSoldier.instantiate()

		GunSoldier.set_position(GunSoldier.INITIAL_POSITION)

		Root.add_child(GunSoldier)
		
	if MeleeSoldier == null:
		MeleeSoldier = meleeSoldier.instantiate()

		MeleeSoldier.set_position(MeleeSoldier.INITIAL_POSITION)

		Root.add_child(MeleeSoldier)"""
