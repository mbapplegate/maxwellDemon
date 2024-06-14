extends pushableObject

const NUM_POINTS = 32
const FRONT_THICKNESS = 2

const mediumIndex = 1.0

@export var LENS_HEIGHT = 128
@export var focalLength = 128
@export var lensIndex = 2.0
@export var focalSpriteColor : Color = Color.BLUE

var halfAngle = 1.0
var lens_shape = PackedVector2Array()
var lensRadius = 100.0
var lensOrigin:Vector2 = Vector2.LEFT
var minX = 1.0
@onready var curveShape = $Stage/curveFaceArea/curveFaceShape
@onready var flatShape = $Stage/flatFaceArea/flatFaceShape
@onready var lensOutline = $Stage/LensOutline
@onready var frontFocusSprite = $Stage/frontFocus
@onready var rearFocusSprite = $Stage/rearFocus

func _ready():
	isEnergizeable = false
	lensRadius = focalLength * (lensIndex - mediumIndex)-5
	
	set_geometry(lensRadius,LENS_HEIGHT,Vector2.ZERO)
	frontFocusSprite.position = Vector2(focalLength,0.0)
	rearFocusSprite.position = Vector2(-focalLength,0.0)
	frontFocusSprite.self_modulate = focalSpriteColor
	rearFocusSprite.self_modulate = focalSpriteColor
	if not isRotatable and initialAngle != 0:
		$Stage/curveFaceArea.rotation=deg_to_rad(initialAngle)
		$Stage/flatFaceArea.rotation = deg_to_rad(initialAngle)
		$Stage/LensOutline.rotation= deg_to_rad(initialAngle)
	
func set_geometry(newRadius:float, lens_height:float, center:Vector2):
	var rad = newRadius
	halfAngle = asin(lens_height / (2.0 * rad))
	curveShape.position.x = center[0]+FRONT_THICKNESS/2.0+1.0
	curveShape.position.y = center[1]
	lensOrigin = Vector2(-lensRadius+curveShape.position.x+minX/2.0,-curveShape.position.y)
	minX = rad - rad*cos(halfAngle)
	flatShape.shape.size = Vector2(FRONT_THICKNESS,LENS_HEIGHT)
	flatShape.position = Vector2(-(minX+FRONT_THICKNESS)/2.0,0.0)
	set_curve_polygon(minX, rad)

func set_curve_polygon(minXVal : float, rad : float):
	var poly = PackedVector2Array()

	var spacing = 2*halfAngle / (NUM_POINTS-1)

	for i in NUM_POINTS:
		var theta = -halfAngle + spacing*i
		poly.append(Vector2(rad*cos(theta)-rad+curveShape.position.x+minXVal/2.0,rad*sin(theta)+curveShape.position.y))
		lens_shape.append(Vector2((rad)*cos(theta)-rad+2*curveShape.position.x+minXVal/2.0-FRONT_THICKNESS,(rad)*sin(theta)+2*curveShape.position.y))
	
	lens_shape.append(Vector2(-minXVal/2.0 - FRONT_THICKNESS,(rad)*sin(-halfAngle + spacing*(NUM_POINTS-1))+curveShape.position.y))
	lens_shape.append(Vector2(-minXVal/2.0 - FRONT_THICKNESS,-rad*sin(-halfAngle + spacing*(NUM_POINTS-1))+curveShape.position.y))
		
	for i in NUM_POINTS:
		var theta = halfAngle - spacing*i
		var insideRad
		if rad > 0:
			insideRad = rad-FRONT_THICKNESS
		else:
			insideRad = rad+FRONT_THICKNESS
		poly.append(Vector2((insideRad)*cos(theta)-rad+curveShape.position.x+minX/2.0,(insideRad)*sin(theta)+curveShape.position.y))
	
	curveShape.polygon = poly
	lensOutline.polygon = lens_shape

func get_face_polygon():
	return curveShape.polygon
	
func _ray_hit(photonObj:Object, collPoint:Vector2, collNormal:Vector2, _collider:Object):
	if _collider.name == "curveFaceArea":
		#Local collision point
		var locPt = to_local(collPoint)
		#Origin of the circle describing the lens rotated based on the lens rotation
		var rotatedOrigin = lensOrigin.rotated(getRotation())
		#Location along the sweep of the lens corrected for rotation
		var correctedTheta = rotatedOrigin.angle_to_point(locPt)-getRotation()
		#Perpendicular direction (facing inward)
		var perpDir = -Vector2(cos(correctedTheta),sin(correctedTheta))
		#Rotatation corrected
		perpDir = perpDir.rotated(getRotation())
		#var isChanged = false
		#If the dot product is positive then the normal should be outward facing
		if photonObj.propDir.dot(perpDir) > 0:
		#	isChanged = true
			perpDir = -perpDir#-Vector2(cos(-2*correctedTheta),sin(-2*correctedTheta))
		photonObj.refractRay(perpDir, lensIndex, collPoint)
		#### DEBUG STUFF ###########
		#$Sprite2D.position = locPt#Vector2(25*cos(correctedTheta),25*sin(correctedTheta)) + locPt
		#$Sprite2D2.position = 25*collNormal+locPt#Vector2(25*cos(correctedTheta),25*sin(correctedTheta)) + locPt
		#$Sprite2D3.position = 25*perpDir + locPt
		#print(photonObj.propDir.dot(perpDir),", ",photonObj.propDir.dot(collNormal))
		#print(rad_to_deg(correctedTheta), ", ",rotatedOrigin,", ", perpDir,", ",collNormal)
		#################################
	else:
		photonObj.refractRay(collNormal, lensIndex, collPoint)
	
func getFocusPositions():
	var lensAngle = getRotation()
	var frontPos = Vector2(focalLength * cos(lensAngle),focalLength * sin(lensAngle))
	var rearPos = Vector2(-focalLength * cos(lensAngle), -focalLength * sin(lensAngle))
	return [frontPos,rearPos]
	
func update_texture():
	super.update_texture()
	
	if isActive:
		var tween = get_tree().create_tween()
		tween.set_ease(Tween.EASE_IN)
		tween.set_trans(Tween.TRANS_LINEAR)
		tween.tween_property(frontFocusSprite,"scale",Vector2(2,2),0.5)
		var tween2 = get_tree().create_tween()
		tween2.set_ease(Tween.EASE_IN)
		tween2.set_trans(Tween.TRANS_LINEAR)
		tween2.tween_property(rearFocusSprite,"scale",Vector2(2,2),0.5)
	else:
		var tween = get_tree().create_tween()
		tween.set_ease(Tween.EASE_IN)
		tween.set_trans(Tween.TRANS_LINEAR)
		tween.tween_property(frontFocusSprite,"scale",Vector2(1,1),1)
		var tween2 = get_tree().create_tween()
		tween2.set_ease(Tween.EASE_IN)
		tween2.set_trans(Tween.TRANS_LINEAR)
		tween2.tween_property(rearFocusSprite,"scale",Vector2(1,1),0.5)
	
