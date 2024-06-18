extends pushableObject

signal photonDetected(energy)

@onready var idIndicator = $Stage/Pivot/detSprite/IDSprite
#@onready var detector = $Stage/Pivot/detSprite

func _ready():
	isEnergizeable = false
	if not isRotatable and initialAngle != 0:
		$Stage/Pivot.rotation = deg_to_rad(initialAngle)
	
func _ray_hit(photonObj:Object, _collPoint:Vector2, _collNormal:Vector2, collider:Object):
	#print(to_local(_collPoint))
	photonObj.rayDying = true
	#print(collider.name)
	if collider.name == "activeArea":
		photonDetected.emit(photonObj.energy)
