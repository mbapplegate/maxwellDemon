extends pushableObject

const NUM_POINTS = 16
const MIRROR_THICKNESS = 8

@export var focalLength = 128.0
@export var mirrorHeight = 120.0
@export var reflectivity = 1.0
@export var focalSpriteColor : Color = Color.BLUE

var parabolicConstant:float = 1.0
var surfacePolygonPoints = PackedVector2Array()
var outlinePolygonPoints = PackedVector2Array()

@onready var focalSprite = $Stage/focalPoint
@onready var surfaceShape = $Stage/surfaceArea/surfaceShape
@onready var backShape = $Stage/backBody/backArea
@onready var topShape = $Stage/backBody/top
@onready var botShape = $Stage/backBody/bottom
@onready var mirrOutline = $Stage/mirrorOutline

func _ready():
	isEnergizeable = false
	parabolicConstant = 1 / (4.0 * focalLength)
	set_geometry(parabolicConstant,mirrorHeight)
	backShape.shape.size = Vector2(MIRROR_THICKNESS/2.0,mirrorHeight)
	backShape.position = Vector2((-0.75*MIRROR_THICKNESS),0.0)
	
	topShape.shape.size = Vector2(MIRROR_THICKNESS,2)
	topShape.position = Vector2(1,mirrorHeight/2.0-1)
	
	botShape.shape.size = Vector2(MIRROR_THICKNESS,2)
	botShape.position = Vector2(1,-mirrorHeight/2.0+1)
	focalSprite.self_modulate = focalSpriteColor
	if not isRotatable and initialAngle != 0:
		$Stage/mirrorOutline.rotation=deg_to_rad(initialAngle)
		$Stage/backBody.rotation = deg_to_rad(initialAngle)
		$Stage/surfaceArea.rotation = deg_to_rad(initialAngle)
		#focalSprite.rotation = deg_to_rad(initialAngle)
	
	
func set_geometry(quadConst:float, mirrHeight:float):
	#Equation for mirror is x = Ay^2
	#var xMax = (quadConst * mirrHeight * mirrHeight) / 4.0
	focalSprite.position = Vector2(focalLength,0.0).rotated(getRotation())
	var spacing = mirrHeight/(NUM_POINTS-1)
	
	for i in NUM_POINTS:
		var xLoc = spacing*i-mirrorHeight/2.0
		surfacePolygonPoints.append(Vector2(quadConst*(xLoc)*(xLoc),xLoc))
		outlinePolygonPoints.append(Vector2(quadConst*(xLoc)*(xLoc),xLoc))
	
	surfacePolygonPoints.append(Vector2(-MIRROR_THICKNESS/2.0,mirrHeight/2.0))
	surfacePolygonPoints.append(Vector2(-MIRROR_THICKNESS/2.0,-mirrHeight/2.0))
	outlinePolygonPoints.append(Vector2(-MIRROR_THICKNESS,mirrorHeight/2.0))
	outlinePolygonPoints.append(Vector2(-MIRROR_THICKNESS,-mirrorHeight/2.0))
		
	surfaceShape.polygon = surfacePolygonPoints
	mirrOutline.polygon = outlinePolygonPoints
	
func _ray_hit(photonObj:Object, collPoint:Vector2, collNormal:Vector2, collider:Object):
	var ref = randf()
	if (ref < reflectivity):
		if collider.name == "surfaceArea":
			var locPt = to_local(collPoint)
			var yDist = locPt.dot(Vector2.UP.rotated(getRotation()))
			var surfaceSlope = 2*parabolicConstant*yDist
			#var surfacePerp = Vector2.ZERO
			var perpVec = Vector2.ZERO
			if surfaceSlope == 0:
				#surfacePerp = Vector2(1,0)
				perpVec = Vector2(1,0)
			else:
				#surfacePerp = -1/surfaceSlope
				perpVec = Vector2(1,surfaceSlope)
				#if getRotation() < -PI/2 or getRotation() > PI/2:
					#perpVec = Vector2(1,surfaceSlope)
			#print(getRotation(), ", ", parabolicConstant*yDist*yDist,", ", yDist)
			#$Sprite2D.position = locPt
			#$Sprite2D2.position = 50*perpVec.rotated(getRotation()).normalized()+locPt
			#$Sprite2D3.position = 50*collNormal+locPt
			photonObj.reflectRay(perpVec.rotated(getRotation()).normalized(), collPoint)
		else:
			photonObj.reflectRay(collNormal,collPoint)
	else:
		photonObj.stopBeam(collPoint)
		
func update_texture():
	super.update_texture()
	
	if isActive:
		var tween = get_tree().create_tween()
		tween.set_ease(Tween.EASE_IN)
		tween.set_trans(Tween.TRANS_LINEAR)
		tween.tween_property(focalSprite,"scale",Vector2(2,2),0.5)
	
	else:
		var tween = get_tree().create_tween()
		tween.set_ease(Tween.EASE_IN)
		tween.set_trans(Tween.TRANS_LINEAR)
		tween.tween_property(focalSprite,"scale",Vector2(1,1),1)

		
	
