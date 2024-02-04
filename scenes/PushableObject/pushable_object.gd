extends CharacterBody2D
class_name pushableObject

const TILE_SIZE = 32
const ROTATION_INCREMENT = deg_to_rad(15)

@export var sliding_time = 0.2
@export var isPushable = true
@export var isRotatable = true
@export var isEnergizeable = true
@export var isEnergized = false

@onready var sprite = $Sprite2D
@onready var bg = $Background

var isActive = false

var tile_map : TileMap
var isSliding : bool = false
# Called when the node enters the scene tree for the first time.
func initialize(_tile_map: TileMap):
	tile_map = _tile_map
	#self.position = position.snapped(round(self.position)*TILE_SIZE)
	#self.position += Vector2.ONE * TILE_SIZE/2.0
	self.position = calculate_destination(Vector2.ZERO)
	update_texture()
	
func calculate_destination(dir:Vector2):
	var tile_map_position = tile_map.local_to_map(self.position) + Vector2i(dir)
	return tile_map.map_to_local(tile_map_position)

func push(motion:Vector2):
	if isSliding or not isPushable:
		return false
	var move_to = calculate_destination(motion.normalized())
	#print("CanMove: ", can_move(move_to), ", ", move_to, ", ", motion)
	if can_move(move_to):
		var tween = get_tree().create_tween()
		
		tween.set_ease(Tween.EASE_IN)
		tween.set_trans(Tween.TRANS_CUBIC)
		tween.tween_property(self,"global_position",move_to,sliding_time)
		isSliding = true
		await tween.finished
		isSliding = false
		return true
		
	else:
		return false
		
func pull(motion:Vector2):
	if isSliding or not isPushable:
		return
	var move_to = calculate_destination(motion.normalized())
	#print("CanMove: ", can_move(move_to), ", ", move_to, ", ", motion)
	
	var tween = get_tree().create_tween()
	tween.tween_property(self,"global_position",move_to,sliding_time)
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_CUBIC)
	isSliding = true
	await tween.finished
	isSliding = false
		
#	else:
#		return
#
func can_move(destination:Vector2):
	var future_transform = Transform2D(transform)
	future_transform.origin = destination
	return not test_move(future_transform,Vector2.ZERO)
# Called every frame. 'delta' is the elapsed time since the previous frame.
	
func update_texture():
	if isActive:
		bg.texture = load("res://tiles/pushable/pushableBase_BACKGROUND_ACTIVE.png")
	elif isRotatable or isPushable:
		bg.texture = load("res://tiles/pushable/pushableBase_BACKGROUND_NORMAL.png")
	else:
		bg.texture = load("res://tiles/pushable/pushableBase_BACKGROUND_STATIC.png")
	
	if isEnergizeable:
		if isEnergized:
			sprite.texture = load("res://tiles/pushable/pushableBase_ON.png")
		else:
			sprite.texture = load("res://tiles/pushable/pushableBase_OFF.png")
	else:
		sprite.texture = load("res://tiles/pushable/pushableBase_NO_EN.png")
			
func rotateCW():
	if isRotatable:
		sprite.rotation -= ROTATION_INCREMENT
	
func rotateCCW():
	if isRotatable:
		sprite.rotation += ROTATION_INCREMENT
		
func togEnergize():
	if isEnergizeable:
		if isEnergized:
			isEnergized = false
			update_texture()
		else:
			isEnergized = true
			update_texture()
