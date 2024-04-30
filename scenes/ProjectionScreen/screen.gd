extends Node2D

const CCD_WIDTH = 32
const COLL_SHAPE_WIDTH = 2
@export var screenHeight : int = 256
@export var numCCDs    : int = 16

@onready var ccdFrame = $StaticBody2D/CollisionShape2D/VBoxContainer
@onready var ccdShape = $StaticBody2D/CollisionShape2D
var ccdArray = Array()
var energyAbsorbed = Array()
var ccdHeight = 1.0

func _ready():
	ccdHeight = screenHeight / float(numCCDs)
	ccdFrame.size = Vector2(CCD_WIDTH,screenHeight)
	ccdFrame.position = Vector2(-CCD_WIDTH+COLL_SHAPE_WIDTH, -screenHeight/2.0)
	ccdShape.shape.size = Vector2(COLL_SHAPE_WIDTH, screenHeight)
	
	energyAbsorbed.resize(numCCDs)
	energyAbsorbed.fill(Vector3.ZERO)
	
	for i in range(numCCDs):
		ccdArray.append(ColorRect.new())
		ccdArray[i].name = "%02d" % i
		ccdArray[i].size_flags_vertical = Control.SIZE_EXPAND_FILL
		ccdArray[i].color = Color(1.0,0,0)
		ccdFrame.add_child(ccdArray[i])

func _ray_hit(photonObj:Object, collPoint:Vector2, _collNormal:Vector2, _collider:Object):
	photonObj.rayDying = true
	var idx = 0
	var localCollPoint = to_local(collPoint)
	
	while localCollPoint.y > (-screenHeight/2.0+ccdHeight*idx):
		idx += 1
		if idx == numCCDs:
			idx -= 1
			break
	energyAbsorbed[idx] += photonObj.energy * photonObj.rayColor


func _on_timer_timeout():
	if energyAbsorbed.all(isZeroVector):
		pass
	else:
		var maxR = 0.0
		var maxG = 0.0
		var maxB = 0.0
		var minR = 10.0
		var minG = 10.0
		var minB = 10.0
		for i in range(numCCDs):
			if energyAbsorbed[i].x > maxR:
				maxR = energyAbsorbed[i].x
			if energyAbsorbed[i].y > maxG:
				maxG = energyAbsorbed[i].y
			if energyAbsorbed[i].z > maxB:
				maxB = energyAbsorbed[i].z
				
			if energyAbsorbed[i].x < minR:
				minR = energyAbsorbed[i].x
			if energyAbsorbed[i].y < minG:
				minG = energyAbsorbed[i].y
			if energyAbsorbed[i].z < minB:
				minB = energyAbsorbed[i].z
				
		for i in range(numCCDs):
			ccdArray[i].color = normalizeColor(Vector3(minR,minG,minB),Vector3(maxR,maxG,maxB),energyAbsorbed[i])
		energyAbsorbed.fill(Vector3.ZERO)

func normalize(minVal, maxVal, val):
	if minVal == 0 and maxVal == 0:
		return 0
	else:
		return (val - minVal) / (maxVal-minVal)
	
func normalizeColor(minVal, maxVal, val):
	return Color(normalize(minVal.x,maxVal.x,val.x), normalize(minVal.y,maxVal.y,val.y), normalize(minVal.z,maxVal.z,val.z))
	
func isZeroVector(val:Vector3):
	return val == Vector3.ZERO
