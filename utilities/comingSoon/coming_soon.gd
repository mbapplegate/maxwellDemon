extends Node2D



const THIS_SCENE_ALIAS = "ComingSoon"
var nextSceneAlias = LevelInfo.GameFlow[THIS_SCENE_ALIAS]

var signalEmitted : bool = false

signal nextScene(sceneAlias)
	
func _ready():
	for child in get_children():
		if child is pushableObject:
			child.initialize()

func _input(event):
	if not signalEmitted and event.is_pressed():
		nextScene.emit(nextSceneAlias)
		signalEmitted = true
