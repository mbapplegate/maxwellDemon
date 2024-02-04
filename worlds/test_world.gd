extends Node2D

@onready var tmap = $TileMap

# Called when the node enters the scene tree for the first time.
func _ready():
	for child in get_children():
		if child is pushableObject:
			child.initialize(tmap)

func _ray_hit(photonObj:Object, _collPoint:Vector2, _collNormal:Vector2, _collider:Object):
	photonObj.rayDying = true
