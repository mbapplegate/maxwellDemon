extends Node2D

@onready var tmap = $TileMap
@onready var door = $Doorway

var beamGo = false
# Called when the node enters the scene tree for the first time.
func _ready():
	for child in get_children():
		if child is pushableObject:
			child.initialize()

func _ray_hit(photonObj:Object, collPoint:Vector2, _collNormal:Vector2, _collider:Object):
	photonObj.stopBeam(collPoint)
	
func _toggleDoor(val):
	if val:
		door.openDoor()
	else:
		door.closeDoor()


