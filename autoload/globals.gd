extends Node

@onready var Root = get_node("/root/Game")
@onready var Player = Root.get_node("Player")
@onready var GameOverScreen = Root.get_node("GameOverScreen")
@onready var ReplayButton = GameOverScreen.get_node("ColorRect/VBoxContainer/Button")


func _ready():
	GameOverScreen.hide()
	Player.connect("player_died", _on_Player_player_died)
	ReplayButton.connect("pressed", _on_ReplayButton_pressed)


func _on_Player_player_died():
	GameOverScreen.show()


func _on_ReplayButton_pressed():
	GameOverScreen.hide()
