extends Node2D

@export var nextSceneAlias = "Level002"
const THIS_SCENE_ALIAS = "EnergizeLesson"

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
