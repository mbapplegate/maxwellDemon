extends pushableObject

@export var numRaysPerTimeout : int = 1
@export var rayColor : Vector3 = Vector3(0.0, 1.0, 0.0)
@export var timerTimeout : float = 0.125
@onready var ray = preload("res://scenes/LightPacket/light_packet.tscn")
@onready var emitterSprite = $Stage/EmitterSprite

var ledParent = null
var rng = RandomNumberGenerator.new()
var ledEnergy = Vector3.ZERO

func _ready():
	ledParent = get_parent()
	emitterSprite.modulate = Color(rayColor[0], rayColor[1],rayColor[2])
	$Timer.wait_time = timerTimeout
	ledEnergy = rayColor/rayColor.length_squared()

func _ray_hit(photonObj:Object, _collPoint:Vector2, _collNormal:Vector2, _collider:Object):
	photonObj.rayDying = true

func _on_timer_timeout():
	var angle = 0.0
	var uVal= 0.0
	var instance 
	var instanceRed = null
	var instanceGreen = null
	var instanceBlue = null
	if (isEnergized):
		for i in numRaysPerTimeout:
			
			angle = rng.randf_range(-PI/2.0,PI/2.0)
			uVal = rng.randf()
			while uVal > cos(angle):
				#print(uVal, ", ", cos(angle))
				angle = rng.randf_range(-PI/2.0,PI/2.0)
				uVal = rng.randf()
			#print("Timeout. Angle: ",angle)
			#print("Timeout. Angle: ",angle)
			if ledEnergy[0] > 0.1:
				instanceRed = ray.instantiate()
				instanceRed.propDir =Vector2(cos(angle),sin(angle))
				instanceRed.position = to_global(Vector2.ZERO)
				instanceRed.rayColor = Vector3(1,0,0)
				instanceRed.energy = ledEnergy[0]
				instanceRed.lightSource = "LED"
			
			if ledEnergy[1] > 0.1:
				instanceGreen = ray.instantiate()
				instanceGreen.propDir = Vector2(cos(angle),sin(angle))
				instanceGreen.position =to_global(Vector2.ZERO)
				instanceGreen.rayColor = Vector3(0,1,0)
				instanceGreen.energy = ledEnergy[1]
				instanceGreen.lightSource = "LED"
			
			if ledEnergy[2] > 0.1:
				instanceBlue = ray.instantiate()
				instanceBlue.propDir =Vector2(cos(angle),sin(angle))
				instanceBlue.position = to_global(Vector2.ZERO)
				instanceBlue.rayColor = Vector3(0,0,1)
				instanceBlue.energy = ledEnergy[2]
				instanceBlue.lightSource = "LED"
			#instance.scale[0] = 1.0/self.scale[0]
			#instance.scale[1] = 1.0 / self.scale[1]
			if ledParent:
				if instanceRed:
					ledParent.add_child(instanceRed)
				if instanceGreen:
					ledParent.add_child(instanceGreen)
				if instanceBlue:
					ledParent.add_child(instanceBlue)
			else:
				if instanceRed:
					add_child(instanceRed)
				if instanceGreen:
					add_child(instanceGreen)
				if instanceBlue:
					add_child(instanceBlue)
