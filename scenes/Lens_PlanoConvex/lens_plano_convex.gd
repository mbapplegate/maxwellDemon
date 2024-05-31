extends pushableObject

const NUM_POINTS = 64
const FRONT_THICKNESS = 2

const mediumIndex = 1.0

@export var LENS_HEIGHT = 128
@export var focalLength = 128
@export var lensIndex = 2.0
@export var focalSpriteColor : Color = Color.BLUE

var halfAngle = 1.0
var lens_shape = PackedVector2Array()

@onready var curveShape = $Stage/curveFaceArea/curveFaceShape
@onready var flatShape = $Stage/flatFaceArea/flatFaceShape
@onready var lensOutline = $Stage/LensOutline
@onready var frontFocusSprite = $Stage/frontFocus
@onready var rearFocusSprite = $Stage/rearFocus

func _ready():
	isEnergizeable = false
	var radius = focalLength * (lensIndex - mediumIndex)
	set_geometry(radius,LENS_HEIGHT,Vector2.ZERO)
	frontFocusSprite.position = Vector2(focalLength,0.0)
	rearFocusSprite.position = Vector2(-focalLength,0.0)
	frontFocusSprite.self_modulate = focalSpriteColor
	rearFocusSprite.self_modulate = focalSpriteColor
	
func set_geometry(newRadius:float, lens_height:float, center:Vector2):
	var radius = newRadius
	halfAngle = asin(lens_height / (2.0 * radius))
	curveShape.position.x = center[0]+FRONT_THICKNESS/2.0+1.0
	curveShape.position.y = center[1]
	var minX = radius - radius*cos(halfAngle)
	flatShape.shape.size = Vector2(FRONT_THICKNESS,LENS_HEIGHT)
	flatShape.position = Vector2(-(minX+FRONT_THICKNESS)/2.0,0.0)
	set_curve_polygon(minX, radius)

func set_curve_polygon(minX : float, radius : float):
	var poly = PackedVector2Array()

	var spacing = 2*halfAngle / (NUM_POINTS-1)

	for i in NUM_POINTS:
		var theta = -halfAngle + spacing*i
		poly.append(Vector2(radius*cos(theta)-radius+curveShape.position.x+minX/2.0,radius*sin(theta)+curveShape.position.y))
		lens_shape.append(Vector2((radius)*cos(theta)-radius+2*curveShape.position.x+minX/2.0-FRONT_THICKNESS,(radius)*sin(theta)+2*curveShape.position.y))
	
	lens_shape.append(Vector2(-minX/2.0 - FRONT_THICKNESS,(radius)*sin(-halfAngle + spacing*(NUM_POINTS-1))+curveShape.position.y))
	lens_shape.append(Vector2(-minX/2.0 - FRONT_THICKNESS,-radius*sin(-halfAngle + spacing*(NUM_POINTS-1))+curveShape.position.y))
		
	for i in NUM_POINTS:
		var theta = halfAngle - spacing*i
		var insideRad
		if radius > 0:
			insideRad = radius-FRONT_THICKNESS
		else:
			insideRad = radius+FRONT_THICKNESS
		poly.append(Vector2((insideRad)*cos(theta)-radius+curveShape.position.x+minX/2.0,(insideRad)*sin(theta)+curveShape.position.y))
	
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
		
	var newDir = normalIn.rotated(theta2)
	photonObj.propDir = newDir
	photonObj.ray_add_point(photonObj.to_local(collPoint))
	
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
	
