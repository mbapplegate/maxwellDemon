extends Node2D

@onready var tmap = $TileMap
@onready var door = $Doorway
@onready var detMeter = $DetectorMeter

# Called when the node enters the scene tree for the first time.
func _ready():
	detMeter.goalMetChanged.connect(_toggleDoor)
	for child in get_children():
		if child is pushableObject:
			child.initialize()

func _ray_hit(photonObj:Object, _collPoint:Vector2, _collNormal:Vector2, _collider:Object):
	photonObj.rayDying = true
	
func _toggleDoor(val):
	if val:
		door.openDoor()
	else:
		door.closeDoor()
