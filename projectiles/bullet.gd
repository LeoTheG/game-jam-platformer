extends Node2D

class_name Bullet

@export var speed = 1500
@onready var visibleOnScreenNotifier2D = $VisibleOnScreenNotifier2D
@onready var area2D = $Sprite2D/Area2D
@onready var player = Globals.Player

var isFiredByPlayer


func _ready():
	visibleOnScreenNotifier2D.connect("screen_exited", on_screen_exited)
	area2D.connect("body_entered", _on_body_entered)


func _on_body_entered(body):
	if body.name == "Player":
		if isFiredByPlayer:
			return
		player.damage(5)
		queue_free()
	elif body.name == "GunSoldier":
		body.queue_free()


# note: when this node is spawned, need to set rotation
func _process(delta):
	position.x += speed * delta * cos(rotation)
	position.y += speed * delta * sin(rotation)


func on_screen_exited():
	queue_free()
