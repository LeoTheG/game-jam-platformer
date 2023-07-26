extends Node2D

class_name Bullet

@export var speed = 1000
@onready var visibleOnScreenNotifier2D = $VisibleOnScreenNotifier2D


func _ready():
	visibleOnScreenNotifier2D.connect("screen_exited", on_screen_exited)


# note: when this node is spawned, need to set rotation
func _process(delta):
	position.x += speed * delta * cos(rotation)
	position.y += speed * delta * sin(rotation)


func on_screen_exited():
	queue_free()
