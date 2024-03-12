extends pushableObject

signal photonDetected(energy)

@onready var idIndicator = $Stage/IDSprite

func _ready():
	isEnergizeable = false
	
func _ray_hit(photonObj:Object, _collPoint:Vector2, _collNormal:Vector2, collider:Object):
	photonObj.rayDying = true
	if collider.name == "activeArea":
		photonDetected.emit(photonObj.energy)
