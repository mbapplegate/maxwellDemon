extends pushableObject

@export var angleRange : Vector2 = Vector2(-PI/2.0,PI/2.0)
@export var numRaysPerTimeout : int = 1
@export var rayColor : Vector3 = Vector3(1.0, 0, 1.0)
@onready var ray = preload("res://scenes/LightPacket/light_packet.tscn")
@onready var sourceBall = $sourceBall

var sourceParent = null
var rng = RandomNumberGenerator.new()

func _ready():
	isRotatable = false
	sourceParent = get_parent()
	sourceBall.modulate = Color(rayColor[0], rayColor[1],rayColor[2])

func _on_timer_timeout():
	var angle = 0
	var instance 
	var yLoc
	if (isEnergized):
		for i in numRaysPerTimeout:
			
			angle = rng.randf_range(angleRange[0],angleRange[1])
		
			#print("Timeout. Angle: ",angle)
			instance = ray.instantiate()
			instance.propDir = Vector2(cos(angle),sin(angle))
			instance.position = to_global(Vector2.ZERO)
			instance.rayColor = rayColor
			instance.scale[0] = 1.0/self.scale[0]
			instance.scale[1] = 1.0 / self.scale[1]
			if sourceParent:
				sourceParent.add_child(instance)

