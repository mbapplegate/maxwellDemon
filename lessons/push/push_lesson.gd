extends Node2D

@export var nextSceneAlias = "Level004"
const THIS_SCENE_ALIAS = "PushLesson"
@onready var las = $LaserSource2

var signalEmitted : bool = false
var dirIdx = 0

signal nextScene(sceneAlias)
	
func _ready():
	for child in get_children():
		if child is pushableObject:
			child.initialize()
	las.isActive = true
	las.update_texture()

func _input(_event):
	if not signalEmitted:
		nextScene.emit(nextSceneAlias)
		signalEmitted = true


func _on_timer_timeout():
	if dirIdx == 0:
		las.pull(Vector2.RIGHT,null)
		dirIdx += 1
	elif dirIdx == 1:
		las.pull(Vector2.DOWN,null)
		dirIdx += 1
	elif dirIdx == 2:
		las.pull(Vector2.LEFT,null)
		dirIdx += 1
	elif dirIdx == 3:
		las.pull(Vector2.UP,null)
		dirIdx = 0
	else:
		dirIdx = 0
