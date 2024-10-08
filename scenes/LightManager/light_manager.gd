extends Node
class_name LightManager
@onready var beamScene = preload("res://scenes/LightBeam/light_beam.tscn")
var instancedRays = {}
func _ready():
	for child in get_children():
		if child is pushableObject:
			
			child.initialize()
			child.connect("rotationChanged", runAllRays)
			child.connect("stageMoved", runAllRays)
			if child.has_method("_dispersionNeeded"):
				child.connect("disperseBeam",disperseRay)
				child.connect("pulseChildRays", pulseTemp)
			if child.has_method("registerBeams"):
				child.connect("registerRays", makeBeams)
				child.connect("stopRays", haltRays)		
				child.connect("startRays", runAllRays)
				child.connect("sourceMoved", handleSourceMoved)
			elif (child is BeamSplitter):
				child.connect("splitBeam",splitRay)
				child.connect("pulseSplitRays", pulseTemp)
			elif (child is AbsorbFilter):
				child.connect("attenuateBeam",attenuateRay)
				
			
		elif child is InvisibleSource:
			child.connect("registerRays", makeBeams)
			child.connect("stopRays", haltRays)		
			child.connect("startRays", runAllRays)

func runRays(sourceObj:Object):
	if instancedRays.has(sourceObj):	
		for i in instancedRays[sourceObj].size():
			instancedRays[sourceObj][i].clearBeam()
			instancedRays[sourceObj][i].fadeOldPulses(0.5)
			instancedRays[sourceObj][i].propagateBeam()
			#instancedRays[sourceObj][i].swapPulseLines()
			
			
	else:
		pass

func runAllRays(_optional:Object = self):
	_clearMeters()
		
	if instancedRays.has("Temp"):
		if instancedRays["Temp"].size() > 0:
			for i in range(instancedRays["Temp"].size()):
				instancedRays["Temp"][i].fadeOldPulses(.1)
				instancedRays["Temp"][i].killBeam()
			instancedRays["Temp"] = []
	#var raySources = instancedRays.keys()
	for key in instancedRays:
		if key is Object:
			if key.isEnergized:
				runRays(key)
	
func handleSourceMoved(newLocation:Array,newDirection:Array,sourceObj:Object):
	if instancedRays.has(sourceObj):
		for i in range(instancedRays[sourceObj].size()):
			instancedRays[sourceObj][i].clearBeam()
			instancedRays[sourceObj][i].moveBeam(newLocation[i],newDirection[i])
		
		runAllRays()
				 
func haltRays(sourceObj:Object):
	if instancedRays.has(sourceObj):
		#_clearMeters()
		for i in range(instancedRays[sourceObj].size()):
			instancedRays[sourceObj][i].clearBeam()
		
		runAllRays()
		
func splitRay(splitRatio:float, splitDirection:Vector2, splitLocation:Vector2, originalBeam:Object):
	
	var instance = beamScene.instantiate()
	if not instancedRays.has("Temp"):
		instancedRays["Temp"] = []
	instancedRays["Temp"].append(instance)
	add_child(instancedRays["Temp"][-1])
	instancedRays["Temp"][-1].lastCollider = originalBeam.lastCollider
	instancedRays["Temp"][-1].propDir = originalBeam.propDir
	instancedRays["Temp"][-1].defineBeam(splitLocation,originalBeam.rayColor,1-splitRatio,originalBeam.propDir,originalBeam.index_of_refraction)
	instancedRays["Temp"][-1].isPulsing = false
	instancedRays["Temp"][-1].propagateBeam()
	
	#print(instancedRays["Temp"][-1], ", ", splitLocation)
	var splitInstance = beamScene.instantiate()
	instancedRays["Temp"].append(splitInstance)
	add_child(instancedRays["Temp"][-1])
	instancedRays["Temp"][-1].lastCollider = originalBeam.lastCollider
	instancedRays["Temp"][-1].propDir = splitDirection
	instancedRays["Temp"][-1].defineBeam(splitLocation+Vector2(2,2),originalBeam.rayColor,splitRatio,splitDirection,originalBeam.index_of_refraction)
	instancedRays["Temp"][-1].isPulsing = false
	instancedRays["Temp"][-1].propagateBeam()
	
	#await originalBeam.pulseDestroyed
	#instancedRays["Temp"][-1].startPulsing()
	#instancedRays["Temp"][-2].startPulsing()
	#print(len(instancedRays["Temp"]))
	
func disperseRay(dispLocation:Vector2,dispDirection:Array, IOR:Vector3, energies:Vector3, originalBeam:Object):
	if not instancedRays.has("Temp"):
		instancedRays["Temp"] = []
	#print(energies)
	for i in range(3):
		if energies[i] > 0:
			var instance = beamScene.instantiate()
			var dispColor = Vector3.ZERO
			dispColor[i] = 1
			instancedRays["Temp"].append(instance)	
			add_child(instancedRays["Temp"][-1])
			instancedRays["Temp"][-1].lastCollider = originalBeam.lastCollider
			instancedRays["Temp"][-1].propDir = dispDirection[i]
			instancedRays["Temp"][-1].index_of_refraction = IOR[i]
			instancedRays["Temp"][-1].defineBeam(dispLocation+Vector2(2,2),dispColor,energies[i],dispDirection[i],IOR[i])
			instancedRays["Temp"][-1].propagateBeam()
			instancedRays["Temp"][-1].isPulsing = false
			
func makeBeams(locations:Array,color:Vector3,energy:float,direction:Array,IOR:float,sourceObj:Object):
	#print("Making beams")
	if instancedRays.has(sourceObj):
		for i in instancedRays[sourceObj].size():
			instancedRays[sourceObj][i].defineBeam(locations[i],color,energy,direction[i], IOR)
	else:
		instancedRays[sourceObj] = []
		for i in locations.size():
			var instance = beamScene.instantiate()
			instancedRays[sourceObj].append(instance)
			add_child(instancedRays[sourceObj][i])
			instancedRays[sourceObj][i].defineBeam(locations[i],color,energy,direction[i],IOR)
	#print(sourceObj.isEnergized)
	if sourceObj.isEnergized:
		runAllRays(sourceObj)
		
func attenuateRay(beamLocation:Vector2, beamColor:Vector3, beamEnergy:float, originalBeam:Object):
	
	var instance = beamScene.instantiate()
	if not instancedRays.has("Temp"):
		instancedRays["Temp"] = []
	instancedRays["Temp"].append(instance)
	add_child(instancedRays["Temp"][-1])
	instancedRays["Temp"][-1].lastCollider = originalBeam.lastCollider
	instancedRays["Temp"][-1].propDir = originalBeam.propDir
	instancedRays["Temp"][-1].rayColor = beamColor
	instancedRays["Temp"][-1].defineBeam(beamLocation,beamColor,beamEnergy,originalBeam.propDir,originalBeam.index_of_refraction)
	instancedRays["Temp"][-1].propagateBeam()

func pulseTemp():
	for ray in instancedRays["Temp"]:
		if not ray.isPulsing:
			ray.startPulsing()
			
func _clearMeters():
	for child in get_children():
		if child is PointDetector:
			child.resetBeamDetected()
			for grandchild in child.get_children():
				if grandchild is DigitalMeter:
					grandchild.clearMeter()
