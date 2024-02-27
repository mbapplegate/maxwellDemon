extends pushableObject

@export var reflectivity = 0.5
@export var splitterIndex = 2.0
@onready var ray = preload("res://scenes/LightPacket/light_packet.tscn")
@onready var splitter = $Stage/splitterArea

const mediumIndex = 1.0
var splitterParent = null

func _ready():
	isEnergizeable = false
	splitterParent = get_parent()
	
	
func _ray_hit(photonObj:Object, collPoint:Vector2, collNormal:Vector2, collider:Object):

	if collider == splitter:
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
	else:
		var normalIn = -collNormal;
		var theta1 = normalIn.angle_to(photonObj.propDir);
		var theta2
		#Going from high index to low index
		if photonObj.index_of_refraction > mediumIndex:
			theta2 = asin(splitterIndex/mediumIndex * sin(theta1))
			photonObj.index_of_refraction = mediumIndex
		#Going from low index to high index
		else:
			theta2 = asin(mediumIndex/splitterIndex*sin(theta1))
			photonObj.index_of_refraction = splitterIndex
		
		photonObj.ray_add_point(photonObj.to_local(collPoint))
		var newDir = normalIn.rotated(theta2)
		photonObj.propDir = newDir
	
