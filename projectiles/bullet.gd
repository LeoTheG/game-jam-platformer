extends Node2D

class_name Bullet
var GunSoldier = load("res://characters/gun_soldier.tscn")
var MeleeSoldier = load("res://characters/melee_soldier.tscn")
var tilemap = Globals.Map
@export var speed = 1500
@onready var visibleOnScreenNotifier2D = $VisibleOnScreenNotifier2D
@onready var area2D = $Sprite2D/Area2D
@onready var player = Globals.Player

var isFiredByPlayer


func _ready():
	visibleOnScreenNotifier2D.connect("screen_exited", on_screen_exited)
	area2D.connect("body_entered", _on_body_entered)


func _on_body_entered(body):
	var position_of_interest = body.global_position
	var cell_coords = tilemap.local_to_map(self.position)
	var atlas_coords = Globals.Map.get_cell_atlas_coords ( 0, cell_coords)
	if body.name == "TileMap":
		if atlas_coords ==Vector2i(4,0):
			if !Globals.cellProperties.has(cell_coords):
				Globals.cellProperties[cell_coords] = {"health": 10}
			Globals.cellProperties[cell_coords].health-= 5;
			if Globals.cellProperties[cell_coords].health <=0:
				tilemap.set_cell(0,cell_coords,-1)
			
	if body.name == "Player":
		if isFiredByPlayer:
			return
		player.damage(5)
		queue_free()
	elif body is GunSoldier or body is MeleeSoldier:
		body.damage(5)
		queue_free()


# note: when this node is spawned, need to set rotation
func _process(delta):
	position.x += speed * delta * cos(rotation)
	position.y += speed * delta * sin(rotation)


func on_screen_exited():
	queue_free()
