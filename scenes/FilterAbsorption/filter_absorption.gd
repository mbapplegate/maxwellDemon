extends pushableObject

const mediumIndex = 1.0
const filterIndex = 2.0

@export var filterWidth : int = 8
@export var filterHeight : int = 120
@export var filterAbsorbance : Color = Color(1.0,0.0,0.0)
@onready var filterCenterShape = $Stage/Center/CenterColl
@onready var filterLeftShape = $Stage/Left/WallLeftColl
@onready var filterRightShape = $Stage/Right/WallRightColl
@onready var filterSprite = $ColorRect
@onready var ray = preload("res://scenes/LightPacket/light_packet.tscn")

@onready var filterParent = get_parent()

func _ready():
	filterCenterShape.shape.size = Vector2(2,filterHeight)
	filterCenterShape.position = Vector2.ZERO
	filterLeftShape.shape.size = Vector2(2,filterHeight)
	filterLeftShape.position = Vector2(-filterWidth/2.0+1,0)
	filterRightShape.shape.size = Vector2(2,filterHeight)
	filterRightShape.position = Vector2(filterWidth/2.0-1,0)
	
	filterSprite.size = Vector2(filterWidth,filterHeight)
	filterSprite.position = Vector2(-filterWidth/2.0, -filterHeight/2.0)
	isEnergizeable = false
	filterSprite.color = Color(1.0-filterAbsorbance[0],1.0-filterAbsorbance[1],1.0-filterAbsorbance[2],0.5)

#Function to handle if a ray collides with either the walls of the cube or the splitter
func _ray_hit(photonObj:Object, collPoint:Vector2, collNormal:Vector2, collider:Object):
	if collider == $Stage/Center:
		print("Hit Center")
		#Create new ray
		var instance = ray.instantiate()
		#Color, energy, IOR, and direction are the same as the incoming ray
		var absVector = Vector3(filterAbsorbance[0],filterAbsorbance[1], filterAbsorbance[2])
		instance.rayColor = photonObj.rayColor * (Vector3.ONE-absVector)
		instance.energy = photonObj.energy * (photonObj.rayColor.length_squared() / instance.rayColor.length_squared())
		instance.index_of_refraction = photonObj.index_of_refraction
		#Reflect off the splitter
		instance.propDir = photonObj.propDir
		#Sometimes the collision normal will be NULL, so check that
		instance.global_position = collPoint
		#If the splitter isn't root then add the child to the parent
		if filterParent:
			instance.lightSource = "filterAbs"
			filterParent.add_child(instance)
		#Otherwise make it a child of itself (mostly for debugging)
		else:
			instance.position = to_local(collPoint)
			add_child(instance)
		#Update photon packet energies depending on reflectivity
		instance.update_energy(instance.energy)
		photonObj.rayDying = true
	else:
		print(collider)
		var normalIn = -collNormal;
		var theta1 = normalIn.angle_to(photonObj.propDir);
		var theta2
		#Going from high index to low index
		if photonObj.index_of_refraction > mediumIndex:
			theta2 = asin(filterIndex/mediumIndex * sin(theta1))
			photonObj.index_of_refraction = mediumIndex
		#Going from low index to high index
		else:
			theta2 = asin(mediumIndex/filterIndex*sin(theta1))
			photonObj.index_of_refraction = filterIndex
		#Add the point to the photon packet
		
		var newDir = normalIn.rotated(theta2)
		photonObj.propDir = newDir
		
		photonObj.ray_add_point(photonObj.to_local(collPoint))
