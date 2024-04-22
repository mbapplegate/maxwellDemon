extends pushableObject

const SPRITE_LENGTH = 120.0
const mediumIndex = 1.0
const lensIndex = 2.0
@export var reflectivity:float = 1.0 
@export var MirrorLength : int = 120
@onready var mirror = $Stage/Sprite2D
#@onready var frontShape = $Stage/Sprite2D/Front/CollisionShape2D
#@onready var backShape = $Stage/Sprite2D/Back/CollisionShape2D

func _ready():
	isEnergizeable = false
	#frontShape.shape.size.x = MirrorLength
	#backShape.shape.size.x = MirrorLength
	mirror.scale.x = MirrorLength / SPRITE_LENGTH
	if not isRotatable and initialAngle != 0:
		mirror.rotation=deg_to_rad(initialAngle)

func _ray_hit(photonObj:Object, collPoint:Vector2, collNormal:Vector2, collider:Object):
	if collider.name == "Front":
		var ref = randf()
		if (ref < reflectivity):
			var newDir = photonObj.propDir.bounce(collNormal).normalized()
			photonObj.propDir = newDir
			photonObj.ray_add_point(photonObj.to_local(collPoint))
		else:
			photonObj.rayDying = true
	elif collider.name == "Back":
		photonObj.rayDying = true
	else:
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
