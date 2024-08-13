extends Node
class_name LightManager
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
			elif child is BeamSplitter:
				child.connect("splitBeam",splitRay)
			else:
				child.connect("rotationChanged", runAllRays)
				child.connect("stageMoved", runAllRays)

func runRays(sourceObj:Object):
	if instancedRays.has(sourceObj):
		_clearMeters()
		
		if instancedRays.has("Temp"):
			if instancedRays["Temp"].size() > 0:
				for i in range(instancedRays["Temp"].size()):
					instancedRays["Temp"][i].queue_free()
				instancedRays["Temp"] = []
			
		for i in instancedRays[sourceObj].size():
			instancedRays[sourceObj][i].clearBeam()
			instancedRays[sourceObj][i].propagateBeam()
	else:
		pass

func runAllRays():
	#var raySources = instancedRays.keys()
	for key in instancedRays:
		if key is Object:
			runRays(key)
	
func handleSourceMoved(newLocation:Array,newDirection:Vector2,sourceObj:Object):
	if instancedRays.has(sourceObj):
		_clearMeters()
		for i in range(instancedRays[sourceObj].size()):
			instancedRays[sourceObj][i].clearBeam()
			instancedRays[sourceObj][i].moveBeam(newLocation[i],newDirection)
		if instancedRays.has("Temp"):
			if instancedRays["Temp"].size() > 0:
				for i in range(instancedRays["Temp"].size()):
					instancedRays["Temp"][i].queue_free()
				instancedRays["Temp"] = []
		if sourceObj.isEnergized:
			runRays(sourceObj)
				 
func haltRays(sourceObj:Object):
	if instancedRays.has(sourceObj):
		_clearMeters()
		for i in range(instancedRays[sourceObj].size()):
			instancedRays[sourceObj][i].clearBeam()
	if instancedRays.has("Temp"):
		if instancedRays["Temp"].size() > 0:
			for i in range(instancedRays[sourceObj].size()):
				instancedRays["Temp"][i].queue_free()
			instancedRays["Temp"] = []
		
func splitRay(splitRatio:float, splitDirection:Vector2, splitLocation:Vector2, originalBeam:Object):
	#print("Splitting in manager")
	var instance = beamScene.instantiate()
	instancedRays["Temp"] = []
	instancedRays["Temp"].append(instance)
	add_child(instancedRays["Temp"][-1])
	instancedRays["Temp"][-1].lastCollider = originalBeam.lastCollider
	instancedRays["Temp"][-1].defineBeam(splitLocation,originalBeam.rayColor,1-splitRatio,originalBeam.propDir,originalBeam.index_of_refraction)
	instancedRays["Temp"][-1].propagateBeam()
	
	#print(instancedRays["Temp"][-1], ", ", splitLocation)
	var splitInstance = beamScene.instantiate()
	instancedRays["Temp"].append(splitInstance)
	add_child(instancedRays["Temp"][-1])
	instancedRays["Temp"][-1].lastCollider = originalBeam.lastCollider
	instancedRays["Temp"][-1].defineBeam(splitLocation+Vector2(2,2),originalBeam.rayColor,splitRatio,splitDirection,originalBeam.index_of_refraction)
	instancedRays["Temp"][-1].propagateBeam()
	
	
func makeBeams(locations:Array,color:Vector3,energy:float,direction:Vector2,IOR:float,sourceObj:Object):
	if instancedRays.has(sourceObj):
		for i in instancedRays[sourceObj].size():
			instancedRays[sourceObj][i].defineBeam(locations[i],color,energy,direction, IOR)
	else:
		instancedRays[sourceObj] = []
		for i in locations.size():
			var instance = beamScene.instantiate()
			instancedRays[sourceObj].append(instance)
			add_child(instancedRays[sourceObj][i])
			instancedRays[sourceObj][i].defineBeam(locations[i],color,energy,direction,IOR)
	if sourceObj.isEnergized:
		runRays(sourceObj)
		
func _clearMeters():
	for child in get_children():
		if child is PointDetector:
			for grandchild in child.get_children():
				if grandchild is DigitalMeter:
					grandchild.clearMeter()
