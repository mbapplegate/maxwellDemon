extends Node2D
@export var absorbs:bool = false
@export var detectorHeight:int = 128
@export var detectorWidth:int = 16

@onready var detPoly = $detectorPoly
@onready var detShape = $detectorPoly/detectorArea/detectorShape

signal detectedPhoton(loc:float, en:float)

func _ready():
	detPoly.polygon = PackedVector2Array([Vector2(-detectorWidth/2.0,-detectorHeight/2.0),
	Vector2(-detectorWidth/2.0,detectorHeight/2.0),
	Vector2(detectorWidth/2.0,detectorHeight/2.0),
	Vector2(detectorWidth/2.0,-detectorHeight/2.0)])
	
	detShape.shape.size = Vector2(2,detectorHeight)
	detShape.position = Vector2.ZERO
	
func _ray_hit(photonObj:Object, collPoint:Vector2, _collNormal:Vector2, _collider:Object):
	var localPoint = to_local(collPoint)
	var pointPct = localPoint.y / detectorHeight + 0.5
	detectedPhoton.emit(pointPct,photonObj.energy)
	if (absorbs):
		photonObj.rayDying = true
