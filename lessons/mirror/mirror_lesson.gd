extends Node2D

@export var nextSceneAlias = "Level007"
const THIS_SCENE_ALIAS = "MirrorLesson"

var signalEmitted : bool = false
var dirIdx = 0
@onready var lref = $LeftReflected
@onready var rref = $RightReflected

signal nextScene(sceneAlias)
	
func _ready():
	for child in get_children():
		if child is pushableObject:
			child.initialize()
	#animateLeft()

func _input(event):
	if not signalEmitted and event.is_pressed():
		nextScene.emit(nextSceneAlias)
		signalEmitted = true
		
func animateLeftForward():
	var tween = get_tree().create_tween()
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(lref,"rotation",PI-deg_to_rad(90-$FlatMirror.initialAngle),3)
	
func animateRightForward():
	var tween = get_tree().create_tween()
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(rref,"rotation",PI-deg_to_rad(90-$FlatMirror2.initialAngle),3)
	
func animateLeftBack():
	var tween = get_tree().create_tween()
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(lref,"rotation",0,3)
	
func animateRightBack():
	var tween = get_tree().create_tween()
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(rref,"rotation",0,3)


func _on_timer_timeout():
	if lref.rotation == 0:
		await animateLeftForward()
	else:
		await animateLeftBack()
	$Timer2.start()


func _on_timer_2_timeout():
	if rref.rotation == 0:
		await animateRightForward()
	else:
		await animateRightBack()
	$Timer.start()
