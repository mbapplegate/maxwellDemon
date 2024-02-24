extends pushableObject

@export var reflectivity:float = 1.0 


func _ready():
	isEnergizeable = false

func _ray_hit(photonObj:Object, collPoint:Vector2, collNormal:Vector2, _collider:Object):
	var ref = randf()
	if (ref < reflectivity):
		var newDir = photonObj.propDir.bounce(collNormal).normalized()
		photonObj.propDir = newDir
		photonObj.ray_add_point(photonObj.to_local(collPoint))
	else:
		photonObj.rayDying = true
