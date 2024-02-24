extends pushableObject

const NUM_POINTS = 64
const FRONT_THICKNESS = 2
const LENS_HEIGHT = 120
const mediumIndex = 1.0

var radius = 150
@export var focalLength = 128
@export var lensIndex = 2.0

var halfAngle = 1.0
var minX
var lens_shape = PackedVector2Array()

@onready var curveShape = $Stage/curveFaceArea/curveFaceShape
@onready var flatShape = $Stage/flatFaceArea/flatFaceShape
@onready var lensOutline = $Stage/LensOutline
@onready var frontFocusSprite = $Stage/frontFocus
@onready var rearFocusSprite = $Stage/rearFocus

func _ready():
	isEnergizeable = false
	radius = focalLength * (lensIndex - mediumIndex)
	set_geometry(radius,LENS_HEIGHT,Vector2.ZERO)
	flatShape.shape.size = Vector2(FRONT_THICKNESS,LENS_HEIGHT)
	flatShape.position = Vector2(-FRONT_THICKNESS/2.0,0.0)
	frontFocusSprite.position = Vector2(focalLength,0.0)
	rearFocusSprite.position = Vector2(-focalLength,0.0)
	
func set_geometry(newRadius:float, lens_height:float, center:Vector2):
	radius = newRadius
	halfAngle = asin(lens_height / (2.0 * radius))
	curveShape.position.x = center[0]+FRONT_THICKNESS/2.0+1.0
	curveShape.position.y = center[1]
	minX = radius - radius*cos(halfAngle)
	set_curve_polygon()

func set_curve_polygon():
	var poly = PackedVector2Array()

	var spacing = 2*halfAngle / (NUM_POINTS-1)

	for i in NUM_POINTS:
		var theta = -halfAngle + spacing*i
		poly.append(Vector2(radius*cos(theta)-radius+curveShape.position.x+minX,radius*sin(theta)+curveShape.position.y))
		lens_shape.append(Vector2((radius)*cos(theta)-radius+2*curveShape.position.x+minX-FRONT_THICKNESS,(radius)*sin(theta)+2*curveShape.position.y))
	
	lens_shape.append(Vector2(-2.0,(radius)*sin(-halfAngle + spacing*(NUM_POINTS-1))+curveShape.position.y))
	lens_shape.append(Vector2(-2.0,-radius*sin(-halfAngle + spacing*(NUM_POINTS-1))+curveShape.position.y))
		
	for i in NUM_POINTS:
		var theta = halfAngle - spacing*i
		var insideRad
		if radius > 0:
			insideRad = radius-FRONT_THICKNESS
		else:
			insideRad = radius+FRONT_THICKNESS
		poly.append(Vector2((insideRad)*cos(theta)-radius+curveShape.position.x+minX,(insideRad)*sin(theta)+curveShape.position.y))
	
	curveShape.polygon = poly
	lensOutline.polygon = lens_shape

func get_face_polygon():
	return curveShape.polygon
	
func _ray_hit(photonObj:Object, collPoint:Vector2, collNormal:Vector2, _collider:Object):
	var normalIn = -collNormal;
	var theta1 = normalIn.angle_to(photonObj.propDir);
	var theta2
	#Going from high index to low index
	if photonObj.index_of_refraction > mediumIndex:
		theta2 = asin(lensIndex/mediumIndex * sin(theta1))
		photonObj.index_of_refraction = mediumIndex
	#Going from low index to high index
	else:
		theta2 = asin(mediumIndex/lensIndex*sin(theta1))
		photonObj.index_of_refraction = lensIndex
	
	photonObj.ray_add_point(photonObj.to_local(collPoint))
	var newDir = normalIn.rotated(theta2)
	photonObj.propDir = newDir
