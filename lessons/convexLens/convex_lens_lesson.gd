extends Node2D

@export var nextSceneAlias = "Level008"
const THIS_SCENE_ALIAS = "ConvexLensLesson"

var signalEmitted : bool = false
var yComponent = 0
var numLensesInAction = 1
var yIncreasing = true
var yMovingOut = true

var initialY : int = 0

signal nextScene(sceneAlias)
	
func _ready():
	for child in get_children():
		if child is pushableObject:
			child.initialize()
	$InvisibleSource/Timer.stop()
	$InvisibleSource5/Timer.stop()
	$InvisibleSource2/Timer.stop()
	$InvisibleSource6/Timer.stop()
	initialY = $InvisibleSource5.position.y
	$explan2.self_modulate = Color(1,1,1,0)
	$explan3.self_modulate = Color(1,1,1,0)

func _input(event):
	if event.is_pressed():
		if not signalEmitted:
			nextScene.emit(nextSceneAlias)
			signalEmitted = true

func _on_timer_timeout():
	if numLensesInAction  > 1:
		if yIncreasing:
			yComponent += 0.01
		else:
			yComponent -= 0.01
			
		$InvisibleSource.propagationDirection.y = yComponent
		$InvisibleSource2.propagationDirection.y = -yComponent
		
		if yComponent == 0.08:
			yIncreasing = false
		elif yComponent == -0.08:
			yIncreasing = true
			
	if numLensesInAction > 2:
		if yMovingOut:
			$InvisibleSource5.position.y += 3
			$InvisibleSource6.position.y -= 3
		else:
			$InvisibleSource5.position.y -= 3
			$InvisibleSource6.position.y += 3
			
		if $InvisibleSource5.position.y == initialY + 42:
			yMovingOut = false
		elif $InvisibleSource5.position.y == initialY:
			yMovingOut = true
		
		
		
func _on_timer_2_timeout():
	numLensesInAction += 1
	$InvisibleSource/Timer.start()
	$InvisibleSource2/Timer.start()
	var tween = get_tree().create_tween()
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.tween_property($explan2,"self_modulate",Color(1.0,1.0,1.0,1.0),0.5)
	$Timer3.start()


func _on_timer_3_timeout():
	numLensesInAction += 1
	$InvisibleSource5/Timer.start()
	$InvisibleSource6/Timer.start()
	var tween = get_tree().create_tween()
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.tween_property($explan3,"self_modulate",Color(1.0,1.0,1.0,1.0),0.5)
