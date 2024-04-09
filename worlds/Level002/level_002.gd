extends Node2D

@onready var door = $Doorway
@onready var player = $Player
@onready var tutText= $RichTextLabel

@export var nextSceneAlias = "MainMenu"

func _ready():
	tutText.modulate=Color(1.0,1.0,1.0,0.0)
	player.levelComplete.connect(nextLevel)
	player.objectActiveChanged.connect(isLaserActive)
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
		
func isLaserActive(obj, isActive:bool):
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
	SceneSwitcher.ChangeScene(nextSceneAlias)
