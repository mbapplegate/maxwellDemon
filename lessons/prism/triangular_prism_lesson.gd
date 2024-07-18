extends Node2D

const THIS_SCENE_ALIAS = "TriangularPrismLesson"
var nextSceneAlias = LevelInfo.GameFlow[THIS_SCENE_ALIAS]

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
	$InvisibleSource2/Timer.stop()
	$InvisibleSource3/Timer.stop()
	#initialY = $InvisibleSource5.position.y

func _input(event):
	if event.is_pressed():
		if not signalEmitted:
			nextScene.emit(nextSceneAlias)
			signalEmitted = true


func _on_timer_timeout():
	$Timer2.start()
	$InvisibleSource2/Timer.start()


func _on_timer_2_timeout():
	$InvisibleSource3/Timer.start()
