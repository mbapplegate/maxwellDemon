extends Node2D


const THIS_SCENE_ALIAS = "ConcaveLensLesson"
var nextSceneAlias = LevelInfo.GameFlow[THIS_SCENE_ALIAS]

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
	$Line2D.visible = false
	$Line2D2.visible = false
	$Line2D3.visible = false
	$explan3.visible = false
	update_line1($Line2D.get_point_position(1))
	update_line2($Line2D2.get_point_position(1))
	update_line3($Line2D3.get_point_position(1))
	$explan2.visible = false
	#$LensPlanoConvex.visible = false
	#$LensPlanoConvex.position = Vector2(-100,-100)


func _input(event):
	if event.is_pressed():
		if not signalEmitted:
			nextScene.emit(nextSceneAlias)
			signalEmitted = true



func _on_timer_2_timeout():
	$Timer3.start()
	$Line2D.visible = true
	$Line2D2.visible = true
	$Line2D3.visible = true
	$explan2.visible = true
	
	var tween1 = get_tree().create_tween()
	var tween2 = get_tree().create_tween()
	var tween3 = get_tree().create_tween()
	
	tween1.set_ease(Tween.EASE_IN_OUT)
	tween2.set_ease(Tween.EASE_IN_OUT)
	tween3.set_ease(Tween.EASE_IN_OUT)
	tween1.set_trans(Tween.TRANS_CUBIC)
	tween2.set_trans(Tween.TRANS_CUBIC)
	tween3.set_trans(Tween.TRANS_CUBIC)
	
	tween1.tween_method(update_line1,$Line2D.get_point_position(0), Vector2(288,352),1.5)
	tween2.tween_method(update_line2,$Line2D2.get_point_position(0), Vector2(288,352),1.5)
	tween3.tween_method(update_line3,$Line2D3.get_point_position(0), Vector2(288,352),1.5)
	
func update_line1(new_pos):
	$Line2D.set_point_position(0, new_pos)

func update_line2(new_pos):
	$Line2D2.set_point_position(0, new_pos)
	
func update_line3(new_pos):
	$Line2D3.set_point_position(0, new_pos)

func _updateBeams():
	$LightManager.runAllRays(self)
	
func _on_timer_3_timeout():
	$Line2D.visible = false
	$Line2D2.visible = false
	$Line2D3.visible = false
	$explan3.visible = true
	#$LensPlanoConvex.visible = true
	$LightManager/LensPlanoConcave/Stage/focusSprite.self_modulate = Color(1.0,1.0,1.0,0.0)
	$LightManager/LensPlanoConcave/Stage/focusSprite2.self_modulate = Color(1.0,1.0,1.0,0.0)
	#$LensPlanoConvex.position = Vector2(256,352)
	var tween1 = get_tree().create_tween()
	tween1.set_ease(Tween.EASE_IN_OUT)
	tween1.set_trans(Tween.TRANS_CUBIC)
	tween1.tween_property($LightManager/LensPlanoConvex,"position", Vector2(256,352),1).set_delay(.5)
	tween1.finished.connect(_updateBeams)
	
	var tween2 = get_tree().create_tween()
	tween2.set_ease(Tween.EASE_IN_OUT)
	tween2.set_trans(Tween.TRANS_CUBIC)
	tween2.tween_property($LightManager/LensPlanoConcave,"position", Vector2(416,480),1)
	tween2.finished.connect(_updateBeams)
	var tween3 = get_tree().create_tween()
	tween3.set_ease(Tween.EASE_IN_OUT)
	tween3.set_trans(Tween.TRANS_CUBIC)
	tween3.tween_property($LightManager/LensPlanoConcave,"position", Vector2(416,352),1).set_delay(5)
	tween3.finished.connect(_updateBeams)
	
