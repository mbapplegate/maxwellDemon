extends Node2D

@export var propagationDirection : Vector2 = Vector2.DOWN
@export var sourceColor : Vector3 = Vector3(1.0, 0.0, 0.0)
@export var sourceWidth : int = 32
@export var numRaysPerTimeout : int = 1

var ray = preload("res://scenes/LightPacket/light_packet.tscn")
var rng = RandomNumberGenerator.new()
var invisParent = null
func _ready():
	invisParent = get_parent()



func _on_timer_timeout():
	var rayPos = 0
	var instance = null
	for i in numRaysPerTimeout:
			if sourceWidth > 0:
				rayPos =rng.randf_range(-sourceWidth/2.0,sourceWidth/2.0)
			else:
				rayPos = 0
			#print("Timeout. Angle: ",angle)
			instance = ray.instantiate()
			instance.propDir = propagationDirection.normalized()
			instance.position = to_global(Vector2(rayPos,0.0))
			
			instance.rayColor = sourceColor
			instance.lightSource = "invisible"
			#instance.scale[0] = 1.0/self.scale[0]
			#instance.scale[1] = 1.0 / self.scale[1]
			if invisParent:
				invisParent.add_child(instance)
