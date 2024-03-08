extends Node2D

@export var multiplier = 1.0
@export var multiplierFixed = false
const NUM_GRAPH_POINTS = 16
const SCREEN_HEIGHT = 118.0
const SCREEN_WIDTH = 64.0
const ZERO_LOC = -30
const MULTIPLIER_MAX = 1024.0
const MULTIPLIER_MIN = 1/32.0
@onready var graphLine = $screenSprite/graphLine
var rng = RandomNumberGenerator.new()

var graphXVals = []
var graphYVals = []
var increaseMultiplier = false
var decreaseMultiplier = false

func _ready():
	for child in get_children():
		if child.name == "DetectorElement":
			child.detectedPhoton.connect(_packet_detected)
			
	graphLine.clear_points()
	graphXVals.resize(NUM_GRAPH_POINTS)
	graphXVals.fill(0.0)
	graphYVals.resize(NUM_GRAPH_POINTS)
	graphYVals.fill(0.0)

	for i in NUM_GRAPH_POINTS:
		graphYVals[i] = (-SCREEN_HEIGHT/2.0)+(SCREEN_HEIGHT/(NUM_GRAPH_POINTS-1))*i
		graphLine.add_point(Vector2(ZERO_LOC,graphYVals[i]))

func _draw_graph():
	var numMax = 0
	var numMin = 0
	var maxX = -1000
	var minX = 1000
	var sumX = 0
	for i in NUM_GRAPH_POINTS:
		var thisXVal = min(SCREEN_WIDTH/2.0,max(-SCREEN_WIDTH/2.0,(graphXVals[i]*multiplier+ZERO_LOC)))
		sumX += thisXVal
		if thisXVal > maxX:
			maxX = thisXVal
		if thisXVal < minX:
			minX = thisXVal
			
		if thisXVal == SCREEN_WIDTH/2.0:
			numMax += 1
		elif thisXVal == -SCREEN_WIDTH/2.0:
			numMin += 1
			
		graphLine.set_point_position(i,Vector2(thisXVal,graphYVals[i]))
	
	if not multiplierFixed:
		var avgX = sumX / NUM_GRAPH_POINTS
		if avgX > SCREEN_WIDTH/4.0 or maxX == SCREEN_WIDTH/2.0:
			decreaseMultiplier = true
		if maxX < 0:
			increaseMultiplier = true
		
		#print("Avg: ", avgX, ", Max: ", maxX, ", Inc: ",increaseMultiplier, ", Dec: ", decreaseMultiplier, ", Mult: ",multiplier)
		
func _add_noise(noiseScale:float):
	for i in NUM_GRAPH_POINTS:
		graphXVals[i] += rng.randfn(0,noiseScale)
		
func _clear_graph():
	graphXVals.fill(0.0)

func _packet_detected(location:float, energy:float):
	var ind = max(0,min((NUM_GRAPH_POINTS-1),int(round(location*NUM_GRAPH_POINTS))))
	graphXVals[ind] += (energy)

			
func _on_timer_timeout():
	
	if increaseMultiplier and multiplier < MULTIPLIER_MAX:
		multiplier *= 2
		increaseMultiplier = false
		
	elif decreaseMultiplier and multiplier > MULTIPLIER_MIN:
		multiplier /= 2
		decreaseMultiplier = false
	
	_add_noise(1)
	_draw_graph()
	_clear_graph()
