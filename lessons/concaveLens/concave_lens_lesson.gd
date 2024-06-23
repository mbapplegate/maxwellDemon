extends Node2D

@export var nextSceneAlias = "Level008"
const THIS_SCENE_ALIAS = "ConvexLensLesson"

var signalEmitted : bool = false
var yComponent = 0.0
#var numLensesInAction = 1
var yIncreasing = true
var yMovingOut = true

var initialY : int = 0

signal nextScene(sceneAlias)
	
func _ready():
	for child in get_children():
		if child is pushableObject:
			child.initialize()


func _input(event):
	if event.is_pressed():
		if not signalEmitted:
			nextScene.emit(nextSceneAlias)
			signalEmitted = true

