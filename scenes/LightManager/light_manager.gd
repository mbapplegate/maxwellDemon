extends Node

@onready var beamScene = preload("res://scenes/LightBeam/light_beam.tscn")
var instancedRays = {}
func _ready():
	for child in get_children():
		if child is pushableObject:
			child.initialize()
			if child.has_method("registerBeams"):
				child.connect("registerRays", makeBeams)
				child.connect("stopRays", haltRays)		
				child.connect("startRays", runRays)
				child.connect("sourceMoved", handleSourceMoved)
			else:
				child.connect("rotationChanged", runAllRays)
				child.connect("stageMoved", runAllRays)

func runRays(sourceObj:Object):
	if instancedRays.has(sourceObj):
		for i in instancedRays[sourceObj].size():
			instancedRays[sourceObj][i].clearBeam()
			instancedRays[sourceObj][i].propagateBeam()
	else:
		pass

func runAllRays():
	#var raySources = instancedRays.keys()
	for key in instancedRays:
		runRays(key)
	
func handleSourceMoved(newLocation:Array,newDirection:Vector2,sourceObj:Object):
	if instancedRays.has(sourceObj):
		for i in range(instancedRays[sourceObj].size()):
			instancedRays[sourceObj][i].clearBeam()
			instancedRays[sourceObj][i].moveBeam(newLocation[i],newDirection)
		if sourceObj.isEnergized:
			runRays(sourceObj)
				
				
	
func haltRays(sourceObj:Object):
	if instancedRays.has(sourceObj):
		for i in instancedRays[sourceObj].size():
			instancedRays[sourceObj][i].clearBeam()
	else:
		pass
		
func makeBeams(locations:Array,color:Vector3,energy:float,direction:Vector2,sourceObj:Object):
	if instancedRays.has(sourceObj):
		for i in instancedRays[sourceObj].size():
			instancedRays[sourceObj][i].defineBeam(locations[i],color,energy,direction)
	else:
		instancedRays[sourceObj] = []
		for i in locations.size():
			var instance = beamScene.instantiate()
			instancedRays[sourceObj].append(instance)
			add_child(instancedRays[sourceObj][i])
			instancedRays[sourceObj][i].defineBeam(locations[i],color,energy,direction)
	if sourceObj.isEnergized:
		runRays(sourceObj)
