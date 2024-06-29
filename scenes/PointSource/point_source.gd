extends pushableObject

@export var angleRangeDeg : Vector2 = Vector2(-90,90)
@export var numRaysPerTimeout : int = 1
@export var rayColor : Vector3 = Vector3(1.0, 0, 1.0)
@onready var ray = preload("res://scenes/LightPacket/light_packet.tscn")
@onready var sourceBall = $sourceBall

var sourceParent = null
var pointEnergy = Vector3.ZERO
var rng = RandomNumberGenerator.new()
var angleRange = Vector2.ZERO
const POINT_RADIUS = 8

func _ready():
	sourceParent = get_parent()
	angleRange = Vector2(deg_to_rad(angleRangeDeg.x),deg_to_rad(angleRangeDeg.y))
	isRotatable=false
	sourceBall.modulate = Color(rayColor[0], rayColor[1],rayColor[2])
	pointEnergy = rayColor/rayColor.length_squared()

func _on_timer_timeout():
	var angle = 0.0
	var instanceRed = null
	var instanceGreen = null
	var instanceBlue = null
	if (isEnergized):
		for i in numRaysPerTimeout:
			
			angle = rng.randf_range(angleRange[0],angleRange[1])
		
			#print("Timeout. Angle: ",angle)
			if pointEnergy[0] > 0.1:
				instanceRed = ray.instantiate()
				instanceRed.propDir = Vector2(POINT_RADIUS*cos(angle),POINT_RADIUS*sin(angle))
				instanceRed.position = to_global(Vector2.ZERO)
				instanceRed.rayColor = Vector3(1.0,0.0,0.0)
				instanceRed.energy = pointEnergy[0]
				instanceRed.lightSource = "point"
			if pointEnergy[1] > 0.1:
				instanceGreen = ray.instantiate()
				instanceGreen.propDir = Vector2(POINT_RADIUS*cos(angle),POINT_RADIUS*sin(angle))
				instanceGreen.position = to_global(Vector2.ZERO)
				instanceGreen.rayColor =  Vector3(0.0,1.0,0.0)
				instanceGreen.energy = pointEnergy[1]
				instanceGreen.lightSource = "point"
			if pointEnergy[2] > 0.1:
				instanceBlue = ray.instantiate()
				instanceBlue.propDir = Vector2(POINT_RADIUS*cos(angle),POINT_RADIUS*sin(angle))
				instanceBlue.position = to_global(Vector2.ZERO)
				instanceBlue.rayColor =  Vector3(0.0,0.0,1.0)
				instanceBlue.energy = pointEnergy[2]
				instanceBlue.lightSource = "point"
			#instance.scale[0] = 1.0/self.scale[0]
			#instance.scale[1] = 1.0 / self.scale[1]
			if sourceParent:
				if instanceRed:
					sourceParent.add_child(instanceRed)
				if instanceGreen:
					sourceParent.add_child(instanceGreen)
				if instanceBlue:
					sourceParent.add_child(instanceBlue)

func _ray_hit(photonObj:Object, _collPoint:Vector2, _collNormal:Vector2, _collider:Object):
	photonObj.rayDying = true
