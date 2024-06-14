extends Node2D

@export var nextSceneAlias = "Level0012"
const THIS_SCENE_ALIAS = "ParabolicMirrorLesson"

var signalEmitted : bool = false
var yComponent = 0.0
#var numLensesInAction = 1

signal nextScene(sceneAlias)
	
func _ready():
	for child in get_children():
		if child is pushableObject:
			child.initialize()
	#$InvisibleSource/Timer.stop()
	#$InvisibleSource5/Timer.stop()
	#$InvisibleSource2/Timer.stop()
	#$InvisibleSource6/Timer.stop()
	#initialY = $InvisibleSource5.position.y

func _input(event):
	if event.is_pressed():
		if not signalEmitted:
			nextScene.emit(nextSceneAlias)
			signalEmitted = true
