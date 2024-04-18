extends pushableObject

signal photonDetected(energy)

@onready var idIndicator = $Stage/detSprite/IDSprite
@onready var detector = $Stage/detSprite

func _ready():
	isEnergizeable = false
	if not isRotatable and initialAngle != 0:
		detector.rotation = deg_to_rad(initialAngle)
	
func _ray_hit(photonObj:Object, _collPoint:Vector2, _collNormal:Vector2, collider:Object):
	photonObj.rayDying = true
	if collider.name == "activeArea":
		photonDetected.emit(photonObj.energy)
