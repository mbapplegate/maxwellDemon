extends Node2D


@export var total_height = 120
@export var aperture_width = 24
@export var thickness = 8
@export var snapX : bool = false
@export var snapY : bool = true
const collThickness = 2
const TILE_SIZE = 32

@onready var topShape = $TopPart/TopPartShape
@onready var topTex = $TopPart/TopPartSprite
@onready var botShape = $BotPart/BotPartShape
@onready var botTex = $BotPart/BotPartSprite

signal rayHit(energy)

func _ready():
	var snappedPos = global_position.snapped(Vector2(TILE_SIZE,TILE_SIZE))
	if snapY:
		global_position.y = snappedPos.y
	if snapX:
		global_position.x = snappedPos.x
	var shapeHt = (total_height - aperture_width) / 2.0 #Height of each leaf
	var shapeOffset = (shapeHt + aperture_width) / 2.0
	#print("Ht: ", shapeHt, ", y-Offset: ", shapeOffset)
	topShape.position = Vector2(0,shapeOffset)
	topShape.shape.size = Vector2(collThickness,shapeHt)
	
	botShape.position = Vector2(0,-shapeOffset)
	botShape.shape.size = Vector2(collThickness,shapeHt)
	topTex.position = topShape.position
	topTex.region_rect = Rect2(topShape.position.x, topShape.position.y,thickness, shapeHt)
	
	botTex.position = botShape.position
	botTex.region_rect = Rect2(botShape.position.x,botShape.position.y,thickness, shapeHt)
	
func _ray_hit(photonObj:Object, _collPoint:Vector2, _collNormal:Vector2, _collider:Object):
	rayHit.emit(photonObj.energy)
	photonObj.rayDying = true

