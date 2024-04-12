extends Node2D


@onready var door = $Doorway
@onready var player = $Player
@onready var combiner = $WireCombiner
@onready var goalWire = $goalWire

@export var nextSceneAlias = "MainMenu"
signal nextScene(sceneAlias)
var signalEmitted : bool = false

const WIRE_OFF_COLOR = Color(10/255.0,10/255.0,10/255.0)
const WIRE_ON_COLOR = Color(240/255.0,240/255.0,60/255.0)

func _ready():
	goalWire.modulate = WIRE_OFF_COLOR
	player.levelComplete.connect(nextLevel)
	for child in get_children():
		if child is pushableObject:
			child.initialize()
		elif child is detectorMeter:
			child.goalMetChanged.connect(_toggleDoor)
			
func _toggleDoor(val):
	if val:
		var allGoalsMet = true
		for child in get_children():
			if child is detectorMeter:
				if child.name == "DetectorMeter":
					combiner.updateTerm1(child.goalMet)
				else:
					combiner.updateTerm2(child.goalMet)
				if not child.goalMet:
					allGoalsMet = false
		
		if allGoalsMet:
			goalWire.modulate = WIRE_ON_COLOR
			door.openDoor()
	else:
		goalWire.modulate = WIRE_OFF_COLOR
		door.closeDoor()
		
			
func nextLevel():
	if not signalEmitted:
		nextScene.emit(nextSceneAlias)
		signalEmitted = true
