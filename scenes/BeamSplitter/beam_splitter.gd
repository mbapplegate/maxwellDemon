extends pushableObject

@export var reflectivity = 0.5
@onready var ray = preload("res://scenes/LightPacket/light_packet.tscn")

var splitterParent = null

func _ready():
	isEnergizeable = false
	splitterParent = get_parent()
	
	
func _ray_hit(photonObj:Object, collPoint:Vector2, collNormal:Vector2, _collider:Object):
	var instance = ray.instantiate()
	instance.rayColor = photonObj.rayColor
	instance.energy = photonObj.energy
	instance.index_of_refraction = photonObj.index_of_refraction
	var newDir = photonObj.propDir.bounce(collNormal).normalized()
	instance.propDir =newDir
	instance.global_position = collPoint
	
	#instance.update_energy(instance.energy*(reflectivity))
	if splitterParent:
		splitterParent.add_child(instance)
	else:
		instance.position = to_local(collPoint)
		add_child(instance)
	photonObj.update_energy(photonObj.energy*(1-reflectivity))
	instance.update_energy(instance.energy*reflectivity)
	
