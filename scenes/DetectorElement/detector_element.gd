extends Node2D
@export var detectorHeight:int = 128
@export var detectorWidth:int = 4

@onready var detPoly = $detectorPoly
@onready var detShape = $detectorPoly/detectorArea/detectorShape

func _ready():
	detPoly.polygon = PackedVector2Array([Vector2(-detectorWidth/2.0,-detectorHeight/2.0),
	Vector2(-detectorWidth/2.0,detectorHeight/2.0),
	Vector2(detectorWidth/2.0,detectorHeight/2.0),
	Vector2(detectorWidth/2.0,-detectorHeight/2.0)])
	
	detShape.shape.size = Vector2(detectorWidth,detectorHeight)
	detShape.position = Vector2.ZERO
