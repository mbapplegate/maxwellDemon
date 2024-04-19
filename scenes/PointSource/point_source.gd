extends pushableObject

@export var angleRangeDeg : Vector2 = Vector2(-90,90)
@export var numRaysPerTimeout : int = 1
@export var rayColor : Vector3 = Vector3(1.0, 0, 1.0)
@onready var ray = preload("res://scenes/LightPacket/light_packet.tscn")
@onready var sourceBall = $sourceBall

var sourceParent = null
var rng = RandomNumberGenerator.new()
var angleRange = Vector2.ZERO
const POINT_RADIUS = 8

func _ready():
	sourceParent = get_parent()
	angleRange = Vector2(deg_to_rad(angleRangeDeg.x),deg_to_rad(angleRangeDeg.y))
	isRotatable=false
	sourceBall.modulate = Color(rayColor[0], rayColor[1],rayColor[2])

func _on_timer_timeout():
	var angle = 0.0
	var instance 
	if (isEnergized):
		for i in numRaysPerTimeout:
			
			angle = rng.randf_range(angleRange[0],angleRange[1])
		
			#print("Timeout. Angle: ",angle)
			instance = ray.instantiate()
			instance.propDir = Vector2(POINT_RADIUS*cos(angle),POINT_RADIUS*sin(angle))
			instance.position = to_global(Vector2.ZERO)
			instance.rayColor = rayColor
			#instance.scale[0] = 1.0/self.scale[0]
			#instance.scale[1] = 1.0 / self.scale[1]
			if sourceParent:
				sourceParent.add_child(instance)

func _ray_hit(photonObj:Object, _collPoint:Vector2, _collNormal:Vector2, _collider:Object):
	photonObj.rayDying = true
