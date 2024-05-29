extends Node2D

@export var nextSceneAlias = "Level005"
const THIS_SCENE_ALIAS = "DetectorLesson"

var signalEmitted : bool = false
var dirIdx = 0

signal nextScene(sceneAlias)
	
func _ready():
	for child in get_children():
		if child is pushableObject:
			child.initialize()

func _input(_event):
	if not signalEmitted:
		nextScene.emit(nextSceneAlias)
		signalEmitted = true
