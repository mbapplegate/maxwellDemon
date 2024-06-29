extends Node2D

@export var propagationDirection : Vector2 = Vector2.DOWN
@export var sourceColor : Vector3 = Vector3(1.0, 0.0, 0.0)
@export var sourceWidth : int = 32
@export var numRaysPerTimeout : int = 1
@export var timerTimeout : float = 1.0

@onready var timer = $Timer

var ray = preload("res://scenes/LightPacket/light_packet.tscn")
var rng = RandomNumberGenerator.new()
var invisParent = null
var srcEnergy = Vector3.ZERO
func _ready():
	invisParent = get_parent()
	timer.wait_time = timerTimeout
	srcEnergy = sourceColor/sourceColor.length_squared()


func changeSourceColor(newColor : Vector3):
	sourceColor = newColor
	srcEnergy = sourceColor/sourceColor.length_squared()
	
func _on_timer_timeout():
	var rayPos = 0
	var instanceRed = null
	var instanceGreen = null
	var instanceBlue = null
	for i in numRaysPerTimeout:
			if sourceWidth > 0:
				rayPos =rng.randf_range(-sourceWidth/2.0,sourceWidth/2.0)
			else:
				rayPos = 0
			#print("Timeout. Angle: ",angle)
			if sourceColor[0] > 0.1:
				instanceRed = ray.instantiate()
				instanceRed.propDir =propagationDirection
				instanceRed.position = to_global(Vector2(rayPos,0))
				instanceRed.rayColor = Vector3(1,0,0)
				instanceRed.energy = srcEnergy[0]
				instanceRed.lightSource = "laser"
			
			if sourceColor[1] > 0.1:
				instanceGreen = ray.instantiate()
				instanceGreen.propDir = propagationDirection
				instanceGreen.position = to_global(Vector2(rayPos,0))
				instanceGreen.rayColor = Vector3(0,1,0)
				instanceGreen.energy = srcEnergy[1]
				instanceGreen.lightSource = "laser"
			
			if sourceColor[2] > 0.1:
				instanceBlue = ray.instantiate()
				instanceBlue.propDir =propagationDirection
				instanceBlue.position = to_global(Vector2(rayPos,0))
				instanceBlue.rayColor = Vector3(0,0,1)
				instanceBlue.energy = srcEnergy[2]
				instanceBlue.lightSource = "laser"
			#instance.scale[0] = 1.0/self.scale[0]
			#instance.scale[1] = 1.0 / self.scale[1]
			if invisParent:
				if instanceRed:
					invisParent.add_child(instanceRed)
				if instanceGreen:
					invisParent.add_child(instanceGreen)
				if instanceBlue:
					invisParent.add_child(instanceBlue)
