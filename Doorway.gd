extends Node2D

@onready var leafTimer = $Timer
@onready var up1 = $up1
@onready var up2 = $up2
@onready var up3 = $up3
@onready var up4 = $up4
@onready var down1 = $down1
@onready var down2 = $down2
@onready var down3 = $down3
@onready var down4 = $down4
@onready var doorBodyClosed = $doorBodyClosed
@onready var doorBodyOpen = $doorBodyOpen

const OPENING_TIME =0.5
const SEATING_TIME = 0.5
const DOOR_WIDTH = 96
const DOOR_OFFSET = 0
const LINE_WIDTH = 4

var upLeaves = []
var downLeaves = []
var leafOpenVec = []
#var leafIdx = 0
var isOpening = false
var isClosing = false
var isSeated = false
var startClosedGlobalPosUp = Vector2.ZERO
var startClosedGlobalPosDown = Vector2.ZERO

func _ready():
	upLeaves.append(up1)
	upLeaves.append(up2)
	upLeaves.append(up3)
	upLeaves.append(up4)
	downLeaves.append(down1)
	downLeaves.append(down2)
	downLeaves.append(down3)
	downLeaves.append(down4)
	startClosedGlobalPosUp = up1.global_position
	startClosedGlobalPosDown = down1.global_position
	leafOpenVec.resize(downLeaves.size())
	leafOpenVec.fill(false)
	#openDoor()
	
func openDoor():
	isOpening = true
	isClosing = false
	if not isSeated and leafOpenVec.count(true) == leafOpenVec.size():
		seatLeaves()
	else:
		leafTimer.start()
	
func closeDoor():
	isOpening = false
	isClosing = true
	leafTimer.start()

func _ray_hit(photonObj:Object, _collPoint:Vector2, _collNormal:Vector2, _collider:Object):
	photonObj.rayDying = true


func seatLeaves():
	
	leafTimer.stop()
	var t
	for i in range(upLeaves.size()):
		t = get_tree().create_tween()
		t.set_ease(Tween.EASE_IN)
		t.set_trans(Tween.TRANS_SPRING)
		t.tween_property(upLeaves[i],"global_position",startClosedGlobalPosUp+Vector2((4-i)*LINE_WIDTH,-DOOR_WIDTH),SEATING_TIME)
	for i in range(upLeaves.size()):
		t = get_tree().create_tween()
		t.set_ease(Tween.EASE_IN)
		t.set_trans(Tween.TRANS_SPRING)
		t.tween_property(downLeaves[i],"global_position",startClosedGlobalPosUp+Vector2((4-i)*LINE_WIDTH,DOOR_WIDTH),SEATING_TIME)	
	await t.finished
	isSeated = true
	leafTimer.start()
		
func unseatLeaves():
	var t
	leafTimer.stop()
	for i in range(upLeaves.size()):
		t = get_tree().create_tween()
		t.set_ease(Tween.EASE_OUT)
		t.set_trans(Tween.TRANS_CUBIC)
		t.tween_property(upLeaves[i],"global_position",startClosedGlobalPosUp+Vector2(0,-DOOR_WIDTH),1)
			
	for i in range(downLeaves.size()):
		t = get_tree().create_tween()
		t.set_ease(Tween.EASE_OUT)
		t.set_trans(Tween.TRANS_CUBIC)
		t.tween_property(downLeaves[i],"global_position",startClosedGlobalPosUp+Vector2(0,DOOR_WIDTH),1)
	await t.finished
	isSeated = false
	leafTimer.start()
			
func _toggleLeaf(leafIndex:int, opening:bool):
	var leafUp = upLeaves[leafIndex]
	var leafDown = downLeaves[leafIndex]
	leafOpenVec[leafIndex] = opening
	var tween1 = get_tree().create_tween()
	tween1.set_ease(Tween.EASE_OUT)
	tween1.set_trans(Tween.TRANS_CIRC)
	
	var tween2 = get_tree().create_tween()
	tween2.set_ease(Tween.EASE_OUT)
	tween2.set_trans(Tween.TRANS_CIRC)
	
	if opening:
		tween1.tween_property(leafUp,"global_position",startClosedGlobalPosUp+Vector2(0,-DOOR_WIDTH),OPENING_TIME)
		tween2.tween_property(leafDown,"global_position",startClosedGlobalPosDown+Vector2(0,DOOR_WIDTH),OPENING_TIME)
		if leafOpenVec.count(true) == leafOpenVec.size():
			tween1.connect("finished",seatLeaves)
	else:
		tween1.tween_property(leafUp,"global_position",startClosedGlobalPosUp,OPENING_TIME)
		tween2.tween_property(leafDown,"global_position",startClosedGlobalPosDown,OPENING_TIME)
		#tween1.connect("finished",_setLeafOpenState(leafIndex,false))
	
func _on_timer_timeout():
	if isOpening:
		for i in range(upLeaves.size()):
			if leafOpenVec[i] == false:
				_toggleLeaf(i,true)
				break
		
		leafTimer.start()
		if leafOpenVec.count(true) == leafOpenVec.size():
			doorBodyClosed.set_collision_layer(0)
			doorBodyClosed.set_collision_mask(0)
			doorBodyOpen.set_collision_layer(3)
			doorBodyOpen.set_collision_mask(3)
			isOpening = false
		
	if  isClosing:
		if isSeated:
			unseatLeaves()
		else:
			for i in range(upLeaves.size()-1,-1,-1):
				print(i)
				if leafOpenVec[i]:
					_toggleLeaf(i,false)
					break
			leafTimer.start()
			
			if leafOpenVec.count(false) == leafOpenVec.size():
				doorBodyClosed.set_collision_layer(3)
				doorBodyClosed.set_collision_mask(3)
				doorBodyOpen.set_collision_layer(0)
				doorBodyOpen.set_collision_mask(0)
				isClosing = false	

