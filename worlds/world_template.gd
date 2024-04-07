extends Node2D
class_name WorldTemplate

@onready var tmap = $TileMap
@onready var door = $Doorway
@onready var detMeter = $DetectorMeter
@onready var detLine1 = $DetectorMeter/detLine1
@onready var player = $Player
@onready var wire = $goalWire

var nextSceneAlias : StringName = "MainMenu"
var newScene = null
const WIRE_OFF_COLOR = Color(10/255.0,10/255.0,10/255.0)
const WIRE_ON_COLOR = Color(240/255.0,240/255.0,60/255.0)


# Called when the node enters the scene tree for the first time.
func _ready():
	detLine1.visible=false
	detMeter.setGoalWirePoints(detLine1.points)
	player.levelComplete.connect(_next_level)
	wire.modulate = WIRE_OFF_COLOR
	for child in get_children():
		if child is pushableObject:
			child.initialize()
		elif child is detectorMeter:
			child.goalMetChanged.connect(_toggleDoor)
	

func _ray_hit(photonObj:Object, _collPoint:Vector2, _collNormal:Vector2, _collider:Object):
	photonObj.rayDying = true
	
func _toggleDoor(val):
	if val:
		var allTrue = true
		for child in get_children():
			if child is detectorMeter:
				if not child.goalMet:
					allTrue = false
		if allTrue:
			wire.modulate = WIRE_ON_COLOR
			door.openDoor()
	else:
		wire.modulate = WIRE_OFF_COLOR
		door.closeDoor()
		
func _next_level():
	SceneSwitcher.ChangeScene(nextSceneAlias)
