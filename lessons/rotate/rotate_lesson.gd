extends Node2D

@export var nextSceneAlias = "Level003"
const THIS_SCENE_ALIAS = "RotateLesson"

var signalEmitted : bool = false
var rotIndex = 4
var goingCW = true

signal nextScene(sceneAlias)
	
func _ready():
	for child in get_children():
		if child is pushableObject:
			child.initialize()

func _input(event):
	if not signalEmitted and event.is_pressed():
		nextScene.emit(nextSceneAlias)
		signalEmitted = true


func _on_timer_timeout():
	if goingCW:
		$LaserSource2.rotateCW()
		rotIndex = rotIndex + 1
	else:
		$LaserSource2.rotateCCW()
		rotIndex = rotIndex - 1
		
	if rotIndex == 8 or rotIndex == 0:
		goingCW = not goingCW
