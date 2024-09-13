extends Node2D

@onready var door = $Doorway
@onready var player = $Player
@onready var titleText = $titleText
@onready var laser = $LaserSource
@onready var imagingLens = $LensPlanoConvex

const THIS_SCENE_ALIAS = "Level010"
var nextSceneAlias = LevelInfo.GameFlow[THIS_SCENE_ALIAS]
signal nextScene(sceneAlias)
var signalEmitted : bool = false

func _ready():
	titleText.text = LevelInfo.LevelDictionary[THIS_SCENE_ALIAS].Title
	player.levelComplete.connect(nextLevel)
	LevelInfo.imagingModeChanged.connect(receiveImagingMode)
	for child in get_children():
		if child is pushableObject:
			child.initialize()
		elif child is detectorMeter:
			child.goalMetChanged.connect(_toggleDoor)
		elif child is ImagerObject:
			child.setImagingLens(imagingLens)
			
func _toggleDoor(val):
	if val:
		var allGoalsMet = true
		for child in get_children():
			if child is detectorMeter:
				if not child.goalMet:
					allGoalsMet = false
		
		if allGoalsMet:
			door.openDoor()
			player.teleport_to($Doorway.global_position+Vector2(-64,-32))
	else:
		door.closeDoor()
		
			
func nextLevel():
	if not signalEmitted:
		LevelInfo.imagingModeChanged.disconnect(receiveImagingMode)
		receiveImagingMode(true)
		nextScene.emit(nextSceneAlias)
		signalEmitted = true
		
func receiveImagingMode(val):

	for child in get_children():
		if child is ImagerObject:
			child.changeImagingMode(val)
		elif child is lightPacket:
			if child.lightSource == "laser":
				child.setPaused(val)
	laser.setPaused(val)
	
