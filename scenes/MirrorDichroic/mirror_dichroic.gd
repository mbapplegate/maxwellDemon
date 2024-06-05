extends pushableObject

const mediumIndex = 1.0
const filterIndex = 2.0

@export var filterWidth : int = 8
@export var filterHeight : int = 120
@export var mirrorReflectance : Color = Color(1.0,0.0,0.0)
@onready var filterCenterShape = $Stage/Center/CenterColl
@onready var filterLeftShape = $Stage/Left/WallLeftColl
@onready var filterRightShape = $Stage/Right/WallRightColl
@onready var filterSprite = $Stage/ColorRect
@onready var ray = preload("res://scenes/LightPacket/light_packet.tscn")

@onready var filterParent = get_parent()

func _ready():
	filterCenterShape.shape.size = Vector2(filterWidth,filterHeight)
	filterCenterShape.position = Vector2(filterWidth/2.0,0)
	filterLeftShape.shape.size = Vector2(2,filterHeight)
	filterLeftShape.position = Vector2(-filterWidth/2.0+1,0)
	filterRightShape.shape.size = Vector2(2,filterHeight)
	filterRightShape.position = Vector2(filterWidth/2.0-1,0)
	filterSprite.set_deferred("size", Vector2(filterWidth,filterHeight))
	filterSprite.set_deferred("position",Vector2(0, -filterHeight/2.0))
	#filterSprite.size = Vector2(filterWidth,filterHeight)
	#filterSprite.position = Vector2(-filterWidth/2.0, -filterHeight/2.0)
	isEnergizeable = false
	filterSprite.color = Color(1.0-mirrorReflectance[0],1.0-mirrorReflectance[1],1.0-mirrorReflectance[2],0.75)

#Function to handle if a ray collides with either the walls of the cube or the splitter
func _ray_hit(photonObj:Object, collPoint:Vector2, collNormal:Vector2, collider:Object):
	if collider == $Stage/Center:
		#print("Hit Center")
		#Create new ray
		var transmittedRay = ray.instantiate()
		
		#Color, energy, IOR, and direction are the same as the incoming ray
		var absVector = Vector3(mirrorReflectance[0],mirrorReflectance[1], mirrorReflectance[2])
		transmittedRay.rayColor = photonObj.rayColor * (Vector3.ONE-absVector)
		transmittedRay.energy = photonObj.energy * (sumVector3(transmittedRay.rayColor)/ sumVector3(photonObj.rayColor))
		transmittedRay.index_of_refraction = photonObj.index_of_refraction
		#Reflect off the splitter
		transmittedRay.propDir = photonObj.propDir
		transmittedRay.global_position = collPoint
		
		#If the splitter isn't root then add the child to the parent
		if filterParent:
			transmittedRay.lightSource = "dichroicMirror"
			filterParent.add_child(transmittedRay)
			transmittedRay.addCollisionException($Stage/Center)
		#Otherwise make it a child of itself (mostly for debugging)
		else:
			transmittedRay.position = to_local(collPoint)
			add_child(transmittedRay)
			transmittedRay.addCollisionException($Stage/Center)
			
		if collNormal:
			var reflectedRay = ray.instantiate()
			var newDir = photonObj.propDir.bounce(collNormal.normalized()).normalized()
			reflectedRay.propDir = newDir
			reflectedRay.global_position = collPoint
			reflectedRay.index_of_refraction = photonObj.index_of_refraction
			reflectedRay.energy = photonObj.energy - transmittedRay.energy
			reflectedRay.rayColor = absVector
			
			if filterParent:
				reflectedRay.lightSource = "dichroicMirror"
				filterParent.add_child(reflectedRay)
				reflectedRay.addCollisionException($Stage/Center)
			else:
				reflectedRay.position = to_local(collPoint)
				add_child(reflectedRay)
				reflectedRay.addCollisionException($Stage/Center)
				
		photonObj.rayDying = true
		
	else:
		#print(collider)
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
		photonObj.removeCollisionException($Stage/Center)
		photonObj.ray_add_point(photonObj.to_local(collPoint))

func sumVector3(vec : Vector3):
	return vec[0]+vec[1]+vec[2]
