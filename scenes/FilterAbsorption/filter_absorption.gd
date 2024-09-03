extends pushableObject
class_name AbsorbFilter

const mediumIndex = 1.0
const COLLISION_WIDTH = 6

@export var filterIndex : float = 2.0
@export var filterWidth : int = 20
@export var filterHeight : int = 120
@export var filterAbsorbance : Color = Color(1.0,0.0,0.0)
@onready var filterCenterShape = $Stage/Center/CenterColl
@onready var filterLeftShape = $Stage/Left/WallLeftColl
@onready var filterRightShape = $Stage/Right/WallRightColl
@onready var filterSprite = $Stage/ColorRect
@onready var ray = preload("res://scenes/LightPacket/light_packet.tscn")

@onready var filterParent = get_parent()

signal attenuateBeam(location:Vector2,color:Vector3,energy:float,object:Object)

func _ready():
	filterCenterShape.shape.size = Vector2(COLLISION_WIDTH,filterHeight)
	filterCenterShape.position = Vector2.ZERO
	filterLeftShape.shape.size = Vector2(COLLISION_WIDTH,filterHeight)
	filterLeftShape.position = Vector2(-filterWidth/2.0+1,0)
	filterRightShape.shape.size = Vector2(COLLISION_WIDTH,filterHeight)
	filterRightShape.position = Vector2(filterWidth/2.0-1,0)
	filterSprite.set_deferred("size", Vector2(filterWidth,filterHeight))
	filterSprite.set_deferred("position",Vector2(-filterWidth/2.0, -filterHeight/2.0))
	#filterSprite.size = Vector2(filterWidth,filterHeight)
	#filterSprite.position = Vector2(-filterWidth/2.0, -filterHeight/2.0)
	isEnergizeable = false
	filterSprite.color = Color(1.0-filterAbsorbance[0],1.0-filterAbsorbance[1],1.0-filterAbsorbance[2],0.5)
	filterSprite.pivot_offset = Vector2(filterWidth/2.0,filterHeight/2.0)
	if not isRotatable and initialAngle != 0:
		$Stage/Center.rotation=deg_to_rad(initialAngle)
		$Stage/Left.rotation=deg_to_rad(initialAngle)
		$Stage/Right.rotation=deg_to_rad(initialAngle)
		$Stage/ColorRect.rotation=deg_to_rad(initialAngle)

#Function to handle if a ray collides with either the walls of the cube or the splitter
func _ray_hit(photonObj:Object, collPoint:Vector2, collNormal:Vector2, collider:Object):
	if collider == $Stage/Center:
		
		var newColor = Vector3.ZERO
		for i in range(3):
			newColor[i] = photonObj.rayColor[i]*(1-filterAbsorbance[i])	
			
		if newColor != photonObj.rayColor:
			var oldEnergyVec = photonObj.rayColor.normalized() * photonObj.energy
			var newEnergyVec = oldEnergyVec*newColor
			var newEnergy = newEnergyVec[0]+newEnergyVec[1]+newEnergyVec[2]
			
			photonObj.stopBeam(collPoint)
			if newEnergy > 0.1:
				attenuateBeam.emit(collPoint,newColor,newEnergy,photonObj)
			
	else:
		photonObj.refractRay(collNormal, filterIndex, collPoint)
