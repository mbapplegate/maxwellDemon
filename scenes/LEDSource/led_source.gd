extends pushableObject

@export var numRaysPerTimeout : int = 1
@export var rayColor : Vector3 = Vector3(0.0, 1.0, 0.0)
@onready var ray = preload("res://scenes/LightPacket/light_packet.tscn")
@onready var emitterSprite = $Stage/EmitterSprite

var ledParent = null
var rng = RandomNumberGenerator.new()

func _ready():
	ledParent = get_parent()
	emitterSprite.modulate = Color(rayColor[0], rayColor[1],rayColor[2])

func _ray_hit(photonObj:Object, _collPoint:Vector2, _collNormal:Vector2, _collider:Object):
	photonObj.rayDying = true

func _on_timer_timeout():
	var angle = 0.0
	var uVal= 0.0
	var instance 
	if (isEnergized):
		for i in numRaysPerTimeout:
			
			angle = rng.randf_range(-PI/2.0,PI/2.0)
			uVal = rng.randf()
			while uVal > cos(angle):
				#print(uVal, ", ", cos(angle))
				angle = rng.randf_range(-PI/2.0,PI/2.0)
				uVal = rng.randf()
			#print("Timeout. Angle: ",angle)
			instance = ray.instantiate()
			instance.propDir = Vector2(cos(angle),sin(angle))
			instance.position = to_global(Vector2.ZERO)
			instance.rayColor = rayColor
			#instance.scale[0] = 1.0/self.scale[0]
			#instance.scale[1] = 1.0 / self.scale[1]
			if ledParent:
				ledParent.add_child(instance)
			else:
				add_child(instance)
