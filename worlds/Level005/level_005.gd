extends Node2D


@onready var door = $Doorway
@onready var player = $Player
@onready var combiner = $WireCombiner
@onready var goalWire = $goalWire
@onready var titleText = $titleText

@export var nextSceneAlias = "MirrorLesson"
signal nextScene(sceneAlias)
var signalEmitted : bool = false

const THIS_SCENE_ALIAS = "Level005"

func _ready():
	titleText.text = LevelInfo.LevelDictionary[THIS_SCENE_ALIAS].Title
	goalWire.modulate = LevelInfo.WIRE_OFF_COLOR
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
			goalWire.modulate = LevelInfo.WIRE_ON_COLOR
			door.openDoor()
	else:
		for child in get_children():
			if child is detectorMeter:
				if child.name == "DetectorMeter":
					combiner.updateTerm1(child.goalMet)
				else:
					combiner.updateTerm2(child.goalMet)
		goalWire.modulate = LevelInfo.WIRE_OFF_COLOR
		door.closeDoor()
		
			
func nextLevel():
	if not signalEmitted:
		nextScene.emit(nextSceneAlias)
		signalEmitted = true
