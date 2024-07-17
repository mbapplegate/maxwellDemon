extends Node2D

const THIS_SCENE_ALIAS = "FilterLesson"
var nextSceneAlias = LevelInfo.GameFlow[THIS_SCENE_ALIAS]

var signalEmitted : bool = false
var rng = RandomNumberGenerator.new()
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


func _on_timer_timeout():
	var hasRed = 0.0 if rng.randf()< 0.5 else 1.0
	var hasGreen = 0.0 if rng.randf()< 0.5 else 1.0
	var hasBlue = 0.0 if rng.randf()< 0.5 else 1.0
	
	if hasRed == 0 and hasGreen == 0 and hasBlue == 0:
		hasRed = 1.0

	$InvisibleSource2.sourceColor = Vector3(hasRed,hasGreen,hasBlue)
	
	
