extends Node2D

@onready var door = $Doorway
@onready var player = $Player
@onready var titleText = $titleText
const THIS_SCENE_ALIAS = "Level009"
var nextSceneAlias = LevelInfo.GameFlow[THIS_SCENE_ALIAS]
signal nextScene(sceneAlias)
var signalEmitted : bool = false

func _ready():
	titleText.text = LevelInfo.LevelDictionary[THIS_SCENE_ALIAS].Title
	player.levelComplete.connect(nextLevel)
	for child in get_children():
		if child is pushableObject:
			child.initialize()
			if child is PointDetector:
				child.goalMetChanged.connect(_toggleDoor)
				
		if child is LightManager:
			for grandchild in child.get_children():
				if grandchild is PointDetector:
					grandchild.goalMetChanged.connect(_toggleDoor)
			
func _toggleDoor(val):
	if val:
		var allGoalsMet = true
		for child in get_children():
			if child is detectorMeter:
				if not child.goalMet:
					allGoalsMet = false
		
		if allGoalsMet:
			door.openDoor()
	else:
		door.closeDoor()
		
			
func nextLevel():
	if not signalEmitted:
		nextScene.emit(nextSceneAlias)
		signalEmitted = true
		
