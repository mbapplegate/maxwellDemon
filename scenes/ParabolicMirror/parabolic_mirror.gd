extends pushableObject

const NUM_POINTS = 64
const MIRROR_THICKNESS = 8

@export var focalLength = 128.0
@export var mirrorHeight = 120.0
@export var reflectivity = 1.0

var parabolicConstant:float = 1.0
var surfacePolygonPoints = PackedVector2Array()

@onready var focalSprite = $Stage/focalPoint
@onready var surfaceShape = $Stage/surfaceArea/surfaceShape
@onready var mirrOutline = $Stage/mirrorOutline

func _ready():
	isEnergizeable = false
	parabolicConstant = 1 / (4.0 * focalLength)
	set_geometry(parabolicConstant,mirrorHeight)
	
	
	
func set_geometry(quadConst:float, mirrHeight:float):
	#Equation for mirror is x = Ay^2
	var xMax = (quadConst * mirrHeight * mirrHeight) / 4.0
	focalSprite.position = Vector2(focalLength-xMax,0.0)
	var spacing = mirrHeight/(NUM_POINTS-1)
	
	for i in NUM_POINTS:
		var xLoc = spacing*i-mirrorHeight/2.0
		surfacePolygonPoints.append(Vector2(quadConst*(xLoc)*(xLoc)-xMax,xLoc))
		
	surfacePolygonPoints.append(Vector2(-xMax-MIRROR_THICKNESS,mirrHeight/2.0))
	surfacePolygonPoints.append(Vector2(-xMax-MIRROR_THICKNESS,-mirrHeight/2.0))
		
	surfaceShape.polygon = surfacePolygonPoints
	mirrOutline.polygon = surfacePolygonPoints
	
func _ray_hit(photonObj:Object, collPoint:Vector2, collNormal:Vector2, _collider:Object):
	var ref = randf()
	if (ref < reflectivity):
		var newDir = photonObj.propDir.bounce(collNormal).normalized()
		photonObj.propDir = newDir
		photonObj.ray_add_point(photonObj.to_local(collPoint))
	else:
		photonObj.rayDying = true
		
	
