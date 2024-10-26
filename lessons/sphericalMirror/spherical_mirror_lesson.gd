extends Node2D

const THIS_SCENE_ALIAS = "SphericalMirrorLesson"
var nextSceneAlias = LevelInfo.GameFlow[THIS_SCENE_ALIAS]

var signalEmitted : bool = false
var onSlide2 : bool = false
var yComponent = 0.0
@onready var radiusTween : Tween = get_tree().create_tween()
#var numLensesInAction = 1
@onready var arc = $Arc

signal nextScene(sceneAlias)
	
func _ready():
	for child in get_children():
		if child is pushableObject:
			child.initialize()
	
	#arc.points = getArcPoints(PI/2,0, 192,32)
	radiusTween.set_ease(Tween.EASE_IN_OUT)
	radiusTween.set_trans(Tween.TRANS_LINEAR)
	radiusTween.tween_property($Radius,"rotation",-PI,1.75)
	await radiusTween.finished
	var tween = get_tree().create_tween()
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(arc,"self_modulate",Color(1,1,1,0),1.25).set_delay(1)
	var tween2 = get_tree().create_tween()
	tween2.set_ease(Tween.EASE_IN_OUT)
	tween2.set_trans(Tween.TRANS_CUBIC)   
	tween2.tween_property($Radius,"self_modulate",Color(1,1,1,0),1.25).set_delay(1)
	await tween2.finished
	$explanationText1.visible = false
	$explanationText2.visible = true
	for child in $LightManager2.get_children():
		if child is InvisibleSource:
			child.energizeBeam()
	#$InvisibleSource/Timer.stop()
	#$InvisibleSource5/Timer.stop()
	#$InvisibleSource2/Timer.stop()
	#$InvisibleSource6/Timer.stop()
	#initialY = $InvisibleSource5.position.y
func _process(delta):
	if not signalEmitted and radiusTween.is_running():
		var t = radiusTween.get_total_elapsed_time()
		var currentAngle = Tween.interpolate_value(0.0,-PI,t,1.75,Tween.TRANS_LINEAR,Tween.EASE_IN_OUT)
		arc.points = getArcPoints(currentAngle+PI/2.0,PI/2.0,192.0,32)

func getArcPoints(endAngle:float,startAngle:float, radius : float, numPoints:int)->PackedVector2Array:
	var anglePoints:PackedVector2Array = []
	if endAngle == startAngle:
		return anglePoints
	var angleStep = (endAngle-startAngle)/(numPoints-1)
	#print(startAngle, ", ", endAngle)
	anglePoints.resize(numPoints)
	anglePoints.fill(Vector2.ZERO)
	for i in range(numPoints):
		anglePoints[i] = Vector2(radius*cos(angleStep*i+startAngle), radius*sin(angleStep*i+startAngle))
	
	return anglePoints
func _input(event):
	if event.is_pressed():
		if not signalEmitted:
			signalEmitted = true
			switchSlide()
			onSlide2 = true
		elif onSlide2:
			nextScene.emit(nextSceneAlias)
			onSlide2 = false
			
			
func switchSlide():
	#print("Switching slide")
	var tween = get_tree().create_tween()
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.tween_property($Camera2D,"position",Vector2($Camera2D.position.x, $Camera2D.position.y-540),1.5)
	await tween.finished
	for child in $LightManager.get_children():
		if child is InvisibleSource:
			child.energizeBeam()
	
	for child in $LightManager2.get_children():
		if child is InvisibleSource:
			child.deEnergizeBeam()
			

func _ray_hit(photonObj:Object, collPoint:Vector2, _collNormal:Vector2, _collider:Object):
	photonObj.stopBeam(collPoint)
