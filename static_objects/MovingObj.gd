extends Node2D

@onready var area2D = $Sprite2D/Area2D
@onready var player = Globals.Player
@onready var animationPlayer = $AnimationPlayer
var isCollidingWithPlayer = false
var damageAmount = 10

func _ready():
	animationPlayer.play("move")
	var screenSize = get_viewport().get_visible_rect().size
	area2D.connect("body_entered", _on_body_entered)
	area2D.connect("body_exited", _on_body_exited)

	
func _on_body_entered(body):
	if body.name == "Player":
		isCollidingWithPlayer = true


func _on_body_exited(body):
	if body.name == "Player":
		isCollidingWithPlayer = false


func _process(_delta):
	if isCollidingWithPlayer:
		player.damage(damageAmount)

