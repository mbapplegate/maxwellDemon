extends Node2D

@onready var door = $Doorway
@onready var player = $Player
@onready var titleText = $titleText
@onready var tutText = $RichTextLabel

const THIS_SCENE_ALIAS = "Level003"
var nextSceneAlias = LevelInfo.GameFlow[THIS_SCENE_ALIAS]
signal nextScene(sceneAlias)
var signalEmitted : bool = false

func _ready():
	titleText.text = LevelInfo.LevelDictionary[THIS_SCENE_ALIAS].Title
	tutText.modulate = Color(1.0,1.0,1.0,0.0)
	player.levelComplete.connect(nextLevel)
	player.objectActiveChanged.connect(isLaserActive)
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
			if child is PointDetector:
				if not child.goalMet:
					allGoalsMet = false
		
		if allGoalsMet:
			door.openDoor()
	else:
		door.closeDoor()
		
func isLaserActive(obj, isActive : bool):
	if obj.name == "LaserSource":
		var tween = get_tree().create_tween()
		tween.set_ease(Tween.EASE_IN_OUT)
		tween.set_trans(Tween.TRANS_CUBIC)
		if isActive:
			tween.tween_property(tutText,"modulate",Color(1.0,1.0,1.0,1.0),0.5)
		else:
			tween.tween_property(tutText,"modulate",Color(1.0,1.0,1.0,0.0),0.5)
	else:
		pass
				
func nextLevel():
	if not signalEmitted:
		nextScene.emit(nextSceneAlias)
		signalEmitted = true
