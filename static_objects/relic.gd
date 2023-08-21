extends Node2D

class_name Relic
@onready var area2D = $Sprite2D/Area2D
@onready var animationPlayer = $AnimationPlayer
# Called when the node enters the scene tree for the first time.
func _ready():
	area2D.connect("body_entered", _on_body_entered)
	animationPlayer.play("Floating")
	pass # Replace with function body.
	
func _on_body_entered(body):
	if body.name == "Player":
		handlePlayerEntered()
		queue_free()

func handlePlayerEntered():
	pass
