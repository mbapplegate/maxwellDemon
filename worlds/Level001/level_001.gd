extends Node2D

@onready var door = $Doorway
@onready var player = $Player
@export var nextSceneAlias = "MainMenu"
func _ready():
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
				if not child.goalMet:
					allGoalsMet = false
		
		if allGoalsMet:
			door.openDoor()
	else:
		door.closeDoor()
		
func nextLevel():
	SceneSwitcher.ChangeScene(nextSceneAlias)
