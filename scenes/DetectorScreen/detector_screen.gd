extends Node2D

const NUM_GRAPH_POINTS = 100
const SCREEN_HEIGHT = 118.0
const SCREEN_WIDTH = 64.0
const ZERO_LOC = -24
@onready var graphLine = $screenSprite/graphLine
var rng = RandomNumberGenerator.new()
var multiplier = 1

var graphXVals = []
var graphYVals = []

func _ready():
	graphLine.clear_points()
	graphXVals.resize(NUM_GRAPH_POINTS)
	graphXVals.fill(0.0)
	graphYVals.resize(NUM_GRAPH_POINTS)
	graphYVals.fill(0.0)

	for i in NUM_GRAPH_POINTS:
		graphYVals[i] = (-SCREEN_HEIGHT/2.0)+(SCREEN_HEIGHT/(NUM_GRAPH_POINTS-1))*i
		graphXVals[i] = rng.randfn(0,5)+ZERO_LOC
		graphLine.add_point(Vector2(graphXVals[i],graphYVals[i]))

func _draw_graph():
	for i in NUM_GRAPH_POINTS:
		graphLine.set_point_position(i,Vector2(graphXVals[i]/multiplier,graphYVals[i]))
		
func _add_noise(noiseScale:float):
	for i in NUM_GRAPH_POINTS:
		graphXVals[i] = max(-SCREEN_WIDTH/2.0,min(SCREEN_WIDTH/2.0,graphXVals[i] + rng.randfn(0,noiseScale)+ZERO_LOC))
		
func _clear_graph():
	graphXVals.fill(0.0)

func _packet_detected(location:float, energy:float):
	var ind = int(round(location*NUM_GRAPH_POINTS))
	graphXVals[ind] += energy

func _adjust_multiplier():
	var numMax = graphXVals.count(SCREEN_WIDTH/2.0)
	if numMax > (0.6*NUM_GRAPH_POINTS):
		multiplier /= 2.0
	else:
		var numMin = graphXVals.count(-SCREEN_WIDTH/2.0)
		if numMin > (0.6*NUM_GRAPH_POINTS):
			multiplier *= 2
		
			
func _on_timer_timeout():
	_clear_graph()
	_add_noise(25)
	_adjust_multiplier()
	_draw_graph()
