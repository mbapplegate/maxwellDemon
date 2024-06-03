extends Node2D

@export var nextSceneAlias = "Level007"
const THIS_SCENE_ALIAS = "MirrorLesson"
const ANGLE_DEMO_LEN = 75
const NUM_ARC_POINTS = 32
var signalEmitted : bool = false
var rotatingCCW = true
@onready var lref = $LeftReflected
#@onready var rref = $RightReflected

signal nextScene(sceneAlias)
	
func _ready():
	for child in get_children():
		if child is pushableObject:
			child.initialize()
	var rot = $FlatMirror.getRotation()
	var newLoc = changeLineAngle(rot)
	
	$LeftIncident.set_point_position(2,newLoc)
	$LeftReflected.set_point_position(2,newLoc)
	$Normal.set_point_position(1,Vector2(85*sin(rot),-85*cos(rot)))
	$LeftIncident/IncidentArc.clear_points()
	$LeftIncident/IncidentArc.points = getArcPoints()
	$LeftReflected/ReflectedArc.clear_points()
	$LeftReflected/ReflectedArc.points = getArcPoints()

func _input(event):
	if not signalEmitted and event.is_pressed():
		nextScene.emit(nextSceneAlias)
		signalEmitted = true
		
func animateLeftForward():
	var tween = get_tree().create_tween()
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(lref,"rotation",$FlatMirror.getRotation()+PI/2.0,0.75)

func getArcPoints() -> PackedVector2Array:
	var points = PackedVector2Array()
	var endingAngle = PI/2.0
	var startingAngle = $FlatMirror.getRotation()
	for i in range(NUM_ARC_POINTS):
		var thisAngle = i * (endingAngle-startingAngle)/NUM_ARC_POINTS
		points.append(Vector2(-(ANGLE_DEMO_LEN-25)*sin(thisAngle),-(ANGLE_DEMO_LEN-25)*cos(thisAngle)))
	return points
#func animateRightForward():
	#var tween = get_tree().create_tween()
	#tween.set_ease(Tween.EASE_IN_OUT)
	#tween.set_trans(Tween.TRANS_CUBIC)
	#tween.tween_property(rref,"rotation",PI-deg_to_rad(90-$FlatMirror2.initialAngle),3)
	
func animateLeftBack():
	var tween = get_tree().create_tween()
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(lref,"rotation",0,0.75)
	
#func animateRightBack():
	#var tween = get_tree().create_tween()
	#tween.set_ease(Tween.EASE_IN_OUT)
	#tween.set_trans(Tween.TRANS_CUBIC)
	#tween.tween_property(rref,"rotation",0,3)

func changeLineAngle(angleInRad:float)->Vector2:
	var correctedAngle = PI/2.0 - angleInRad
	var xLoc = -sin(correctedAngle) * ANGLE_DEMO_LEN
	var yLoc = -cos(correctedAngle) * ANGLE_DEMO_LEN
	return Vector2(xLoc,yLoc)

func _on_timer_timeout():
	if lref.rotation == 0:
		await animateLeftForward()
		$Timer.start()
	else:
		await animateLeftBack()
		$Timer2.start()


func _on_timer_2_timeout():
	#if rref.rotation == 0:
		#await animateRightForward()
	#else:
		#await animateRightBack()
	if rotatingCCW:
		$FlatMirror.rotateCCW()
	else:
		$FlatMirror.rotateCW()
	#print("Angle: ",rad_to_deg($FlatMirror.getRotation()))
	if rad_to_deg($FlatMirror.getRotation()) <= 10:
		rotatingCCW = false
	if $FlatMirror.getRotation() >= deg_to_rad($FlatMirror.initialAngle-2):
		rotatingCCW = true
	
	var newLoc = changeLineAngle($FlatMirror.getRotation())
	#print($LeftIncident.points[2])
	#var tween = get_tree().create_tween()
	#tween.set_ease(Tween.EASE_IN_OUT)
	#tween.set_trans(Tween.TRANS_CUBIC)
	#tween.tween_property($LeftIncident,"points[2]",newLoc,0.5)
	var rot = $FlatMirror.getRotation()
	$Normal.set_point_position(1,Vector2(85*sin(rot),-85*cos(rot)))
	$LeftIncident.set_point_position(2,newLoc)
	$LeftReflected.set_point_position(2,newLoc)
	$LeftIncident/IncidentArc.clear_points()
	$LeftIncident/IncidentArc.points = getArcPoints()
	$LeftReflected/ReflectedArc.clear_points()
	$LeftReflected/ReflectedArc.points = getArcPoints()
	#$LeftIncident.position.y-=2
	#$LeftReflected.position.y-=2
	$Timer.start()
