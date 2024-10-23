extends pushableObject


const NUM_POINTS = 32
const MIRROR_THICKNESS = 8

@export var mirrorRadius = 256.0
@export var mirrorHeight = 120.0
@export var reflectivity = 1.0
@export var focalSpriteColor : Color = Color.BLUE

var frontPolygonPoints = PackedVector2Array()
var rearPolygonPoints = PackedVector2Array()
var outlinePolygonPoints = PackedVector2Array()

@onready var focalSprite = $Stage/FocalSprite
@onready var frontShape = $Stage/FrontArea/FrontShape
@onready var rearShape = $Stage/BackArea/BackShape
#@onready var backShape = $Stage/backBody/backArea
#@onready var topShape = $Stage/backBody/top
#@onready var botShape = $Stage/backBody/bottom
@onready var mirrOutline = $Stage/MirrorPolygon

func _ready():
	isEnergizeable = false
	#focalSprite.self_modulate = focalSpriteColor
	
	set_geometry(mirrorRadius,mirrorHeight)
	if not isRotatable and initialAngle != 0:
		$Stage/FrontArea.rotation=deg_to_rad(initialAngle)
		$Stage/BackArea.rotation = deg_to_rad(initialAngle)
		#$Stage/backBody.rotation = deg_to_rad(initialAngle)
		#$Stage/surfaceArea.rotation = deg_to_rad(initialAngle)
		focalSprite.rotation = deg_to_rad(initialAngle)
	
	
func set_geometry(mirrRadius:float, mirrHeight:float):
	#Equation for mirror is x = Ay^2
	#var xMax = (quadConst * mirrHeight * mirrHeight) / 4.0
	focalSprite.position = Vector2(-mirrRadius,0.0).rotated(getRotation())
	var minAngle = asin(mirrHeight/(2.0*mirrRadius))
	var angleSpacing = (2*minAngle)/(NUM_POINTS-1)

	for i in NUM_POINTS:
		var thisAngle = angleSpacing*i-minAngle
		var thisPt = Vector2(mirrRadius*cos(thisAngle)-mirrRadius,mirrRadius*sin(thisAngle))
		frontPolygonPoints.append(thisPt)
		outlinePolygonPoints.append(thisPt)
	
	for i in NUM_POINTS:
		var thisAngle = minAngle-angleSpacing*i
		frontPolygonPoints.append(Vector2((mirrRadius+2.0)*cos(thisAngle)-mirrRadius,(mirrRadius+2.0)*sin(thisAngle)))
	
	for i in NUM_POINTS:
		var thisAngle = angleSpacing*i-minAngle
		rearPolygonPoints.append(Vector2((mirrRadius+MIRROR_THICKNESS-2.0)*cos(thisAngle)-mirrRadius,(mirrRadius+MIRROR_THICKNESS-2.0)*sin(thisAngle)))
		#outlinePolygonPoints.append(Vector2(quadConst*(xLoc)*(xLoc),xLoc))
	
	for i in NUM_POINTS:
		var thisAngle = minAngle-angleSpacing*i
		var thisPt = Vector2((mirrRadius+MIRROR_THICKNESS)*cos(thisAngle)-mirrRadius,(mirrRadius+MIRROR_THICKNESS)*sin(thisAngle))
		rearPolygonPoints.append(thisPt)
		outlinePolygonPoints.append(thisPt)
	
	#surfacePolygonPoints.append(Vector2(MIRROR_THICKNESS,mirrHeight/2.0))
	#surfacePolygonPoints.append(Vector2(MIRROR_THICKNESS,-mirrHeight/2.0))
	#outlinePolygonPoints.append(Vector2(-MIRROR_THICKNESS,mirrorHeight/2.0))
	#outlinePolygonPoints.append(Vector2(-MIRROR_THICKNESS,-mirrorHeight/2.0))
		
	frontShape.polygon = frontPolygonPoints
	rearShape.polygon = rearPolygonPoints
	mirrOutline.polygon = outlinePolygonPoints
	
func _ray_hit(photonObj:Object, collPoint:Vector2, _collNormal:Vector2, collider:Object):
	var ref = 0.0
	if reflectivity < 1.0:
		ref = randf()
		
	if (ref < reflectivity):
		#print(collPoint)
		var locPt = to_local(collPoint)
		var perpVec =collPoint.direction_to(to_global(Vector2(-mirrorRadius,0.0).rotated(getRotation())))
		$Stage/DEBUG.global_position = collPoint
		$Stage/DEBUG2.global_position = collPoint + 64*perpVec
		#if collider.name == "BackArea":
		#	perpVec.y = -perpVec.y
		#var yDist = locPt.dot(Vector2.UP.rotated(getRotation()))
		
		#print(getRotation(), ", ", parabolicConstant*yDist*yDist,", ", yDist)
		#$Sprite2D.position = locPt
		#$Sprite2D2.position = 50*perpVec.rotated(getRotation()).normalized()+locPt
		#$Sprite2D3.position = 50*collNormal+locPt
		photonObj.reflectRay(perpVec, collPoint)
		
		
#func update_texture():
	#super.update_texture()
	#
	#if isActive:
		#var tween = get_tree().create_tween()
		#tween.set_ease(Tween.EASE_IN)
		#tween.set_trans(Tween.TRANS_LINEAR)
		#tween.tween_property(focalSprite,"scale",Vector2(2,2),0.5)
	#
	#else:
		#var tween = get_tree().create_tween()
		#tween.set_ease(Tween.EASE_IN)
		#tween.set_trans(Tween.TRANS_LINEAR)
		#tween.tween_property(focalSprite,"scale",Vector2(1,1),1)
#
		#
	#
#
