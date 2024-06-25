extends Node2D

@onready var door = $Doorway
@onready var player = $Player
@onready var titleText = $titleText
const THIS_SCENE_ALIAS = "Level009b"
@export var nextSceneAlias = "BeamExpanderLesson2"
signal nextScene(sceneAlias)
var signalEmitted : bool = false
var energyBlocked : float = 0.0
var energyDetected : float = 0.0

func _ready():
	titleText.text = LevelInfo.LevelDictionary[THIS_SCENE_ALIAS].Title
	player.levelComplete.connect(nextLevel)
	$StaticIris.rayHit.connect(incrementBlockedCtr)
	$DetectorMeter/PointDetector.photonDetected.connect(incrementDetectedCtr)
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
		
func incrementBlockedCtr(energy):
	energyBlocked += energy
	
func incrementDetectedCtr(energy):
	energyDetected += energy

func _on_timer_timeout():
	var pctDetected = 0.0
	if energyBlocked > 0 or energyDetected > 0:
		pctDetected = energyDetected / (energyBlocked + energyDetected)
		
	$DetectorMeter/PointDetector/RichTextLabel.text = "Detected: %2d\nBlocked: %4d\nPercent: %4.0f%%" % [energyDetected, energyBlocked, (100*pctDetected)]
	energyBlocked = 0.0
	energyDetected = 0.0 # Replace with function body.
