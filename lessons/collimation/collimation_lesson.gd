extends Node2D

@export var nextSceneAlias = "Level009"
const THIS_SCENE_ALIAS = "CollimationLesson"

var signalEmitted : bool = false
var dirIdx = 0

signal nextScene(sceneAlias)
	
func _ready():
	for child in get_children():
		if child is pushableObject:
			child.initialize()

func _input(event):
	if not signalEmitted and event.is_pressed():
		nextScene.emit(nextSceneAlias)
		signalEmitted = true
