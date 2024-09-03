extends pushableObject

const SPRITE_LENGTH = 120.0
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
			photonObj.reflectRay(collNormal,collPoint)
			#print(photonObj.propDir)
			#print(to_local(photonObj.line.get_point_position(photonObj.numPoints-1)))
		else:
			photonObj.stopBeam(collPoint)
	else:
		photonObj.stopBeam(collPoint)
