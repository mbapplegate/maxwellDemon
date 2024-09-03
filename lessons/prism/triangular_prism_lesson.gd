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
	$LightManager/InvisibleSource2.deEnergizeBeam()
	$LightManager/InvisibleSource3.deEnergizeBeam()
	#initialY = $InvisibleSource5.position.y

func _input(event):
	if event.is_pressed():
		if not signalEmitted:
			nextScene.emit(nextSceneAlias)
			signalEmitted = true


func _on_timer_timeout():
	$Timer2.start()
	$LightManager/InvisibleSource2.energizeBeam()


func _on_timer_2_timeout():
	$LightManager/InvisibleSource3.energizeBeam() 	
