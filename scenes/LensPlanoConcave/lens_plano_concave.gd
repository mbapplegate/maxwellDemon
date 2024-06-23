extends pushableObject

const NUM_POINTS = 32
const FRONT_THICKNESS = 2

const mediumIndex = 1.0

@export var LENS_HEIGHT : float = 128
@export_range (-16358,-10) var focalLength : float = -128
@export var lensIndex = 2.0
@export var focalSpriteColor : Color = Color.BLUE

var halfAngle = 1.0
var lens_shape = PackedVector2Array()
var lensRadius = 100.0
var lensOrigin:Vector2 = Vector2.RIGHT

@onready var curveShape = $Stage/FrontFaceArea/curveFaceShape
@onready var flatShape = $Stage/BackFaceArea/flatFaceShape
@onready var lensOutline = $Stage/LensOutline
@onready var focusSprite = $Stage/focusSprite
@onready var focusSprite2 = $Stage/focusSprite2
@onready var botShape = $Stage/BottomFaceArea/BottomShape
@onready var topShape = $Stage/TopFaceArea/TopShape

func _ready():
	isEnergizeable = false
	lensRadius = focalLength * (lensIndex - mediumIndex)
	set_geometry(lensRadius,LENS_HEIGHT,Vector2.ZERO)
	#$Line2D.set_point_position(0,Vector2(0,-LENS_HEIGHT/2.0))
	#$Line2D.set_point_position(1,Vector2(0,LENS_HEIGHT/2.0))

	focusSprite.self_modulate = focalSpriteColor
	focusSprite2.self_modulate=focalSpriteColor

	if not isRotatable and initialAngle != 0:
		var radAngle = deg_to_rad(initialAngle)
		$Stage/FrontFaceArea.rotation=radAngle
		$Stage/BackFaceArea.rotation = radAngle
		$Stage/BottomFaceArea.rotation = radAngle
		$Stage/TopFaceArea.rotation = radAngle
		$Stage/LensOutline.rotation=radAngle
	
func set_geometry(newRadius:float, lens_height:float, center:Vector2):
	halfAngle = asin(lens_height / (2.0 * newRadius))
	curveShape.position.x = center[0]#+FRONT_THICKNESS/2.0+1.0
	curveShape.position.y = center[1]
	var maxX = -newRadius + newRadius*cos(halfAngle)
	
	#print(minX,', ', newRadius*sin(halfAngle), ", ", lens_height)
	#var maxY = newRadius*sin(halfAngle)
	#if maxY < lens_height:
		#lens_height = 2*maxY

	var lensThickness =8*FRONT_THICKNESS + maxX
	#print("concave Thickness: ", lensThickness, "Radius: ", newRadius)
	#Distance from lens at theta=0 to principal plane
	#I want this to be located at Zero
	var apexToPlane = (lensThickness-maxX)/lensIndex
	var backLoc = -(lensThickness-maxX)-apexToPlane
	topShape.position = Vector2(backLoc+lensThickness/2.0,-lens_height/2.0+FRONT_THICKNESS/2.0)
	topShape.shape.size = Vector2(lensThickness-2*FRONT_THICKNESS,FRONT_THICKNESS)
	
	botShape.position = Vector2(backLoc+lensThickness/2.0,lens_height/2.0-FRONT_THICKNESS/2.0)
	botShape.shape.size = Vector2(lensThickness-2*FRONT_THICKNESS,FRONT_THICKNESS)
	
	focusSprite.position = Vector2(focalLength,0.0)
	focusSprite2.position = Vector2(-focalLength,0.0)
	#$Sprite2D.position = Vector2(-apexToPlane,0)
	#print(apexToPlane, ", ", minX)
	#$Sprite2D.position = Vector2.ZERO
	#$Sprite2D2.position = Vector2(-apexToPlane,0)
	#Center of the spherical portion of the lens
	lensOrigin = Vector2(-lensRadius-apexToPlane,0)
	#print(lensRadius, lensOrigin)
	#print("MaxX: ", maxX, ", ApexToPlane: ", apexToPlane, ", Thickness: ", lensThickness, ", Origin: ", lensOrigin)
	flatShape.shape.size = Vector2(FRONT_THICKNESS,lens_height)
	flatShape.position = Vector2(backLoc+FRONT_THICKNESS/2.0,0.0)
	set_curve_polygon(apexToPlane, newRadius, lensThickness)
	#print($Stage/flatFaceArea/flatFaceShape.shape.size)

func set_curve_polygon(distToPrinPlane : float,  rad : float,lensThickness : float):
	var poly = PackedVector2Array()

	var spacing = 2*halfAngle / (NUM_POINTS-1)
	var maxX = -rad + rad*cos(halfAngle)
	for i in NUM_POINTS:
		var theta = -halfAngle + spacing*i
		poly.append(Vector2(rad*cos(theta)-rad-distToPrinPlane,rad*sin(theta)))
		lens_shape.append(Vector2(rad*cos(theta)-rad-distToPrinPlane,rad*sin(theta)))
	
	lens_shape.append(Vector2(-(lensThickness-maxX)-distToPrinPlane,rad*sin(halfAngle)))
	lens_shape.append(Vector2(-(lensThickness-maxX)-distToPrinPlane,rad*sin(-halfAngle)))
	#$Sprite2D.position = Vector2(-4*FRONT_THICKNESS+distToPrinPlane-minX,rad*sin(halfAngle))	
	#$Sprite2D2.position = Vector2(-4*FRONT_THICKNESS+distToPrinPlane-minX,rad*sin(-halfAngle))
	for i in NUM_POINTS:
		var theta = halfAngle - spacing*i
		var insideRad
		if rad > 0:
			insideRad = rad-FRONT_THICKNESS
		else:
			insideRad = rad+FRONT_THICKNESS
		poly.append(Vector2(insideRad*cos(theta)-rad-distToPrinPlane,(insideRad)*sin(theta)))
	
	curveShape.polygon = poly
	lensOutline.polygon = lens_shape

func get_face_polygon():
	return curveShape.polygon
	
func _ray_hit(photonObj:Object, collPoint:Vector2, collNormal:Vector2, _collider:Object):

	if _collider.name == "FrontFaceArea":
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
		#print("Curve: ", photonObj.index_of_refraction)
		#print(photonObj.index_of_refraction)
		#print(collNormal, perpDir)
		#### DEBUG STUFF ###########
		#$Sprite2D.position = Vector2(-4*FRONT_THICKNESS+distToPrinPlane,-rad*sin(halfAngle))
		#$Sprite2D.position = locPt#Vector2(25*cos(correctedTheta),25*sin(correctedTheta)) + locPt
		#$Sprite2D2.position =25*collNormal + locPt#Vector2(25*cos(correctedTheta),25*sin(correctedTheta)) + locPt
		#$Sprite2D.position = 25*perpDir + locPt
		#$Sprite2D.position = Vector2.ZERO
		
		#print(photonObj.propDir.dot(perpDir),", ",photonObj.propDir.dot(collNormal))
		#print(rad_to_deg(correctedTheta), ", ",rotatedOrigin,", ", perpDir,", ",collNormal)
		#################################
	else:
		photonObj.refractRay(collNormal, lensIndex, collPoint)
		#print("Flat: ",photonObj.index_of_refraction)
	
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
		tween.tween_property(focusSprite,"scale",Vector2(2,2),0.5)
		var tween2 = get_tree().create_tween()
		tween2.set_ease(Tween.EASE_IN)
		tween2.set_trans(Tween.TRANS_LINEAR)
		tween2.tween_property(focusSprite2,"scale",Vector2(2,2),0.5)
	
	else:
		var tween = get_tree().create_tween()
		tween.set_ease(Tween.EASE_IN)
		tween.set_trans(Tween.TRANS_LINEAR)
		tween.tween_property(focusSprite,"scale",Vector2(1,1),1)
		var tween2 = get_tree().create_tween()
		tween2.set_ease(Tween.EASE_IN)
		tween2.set_trans(Tween.TRANS_LINEAR)
		tween2.tween_property(focusSprite2,"scale",Vector2(1,1),1)
		
	
