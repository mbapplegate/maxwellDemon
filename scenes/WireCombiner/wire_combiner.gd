extends Node2D

@onready var term1 = $combinerBase/terminalIn1
@onready var term2 = $combinerBase/terminalIn2
@onready var termOut = $combinerBase/terminalOut
@onready var base = $combinerBase
@onready var icon = $combinerBase/Icon

var terminal1Active : bool = false
var terminal2Active : bool = false
var outputActive : bool = false

const FILL_BASE = Color(0.35,0.35,0.35)
const OFF_FILL_TERM = Color(0.5,0.5,0.5)
const ON_FILL_TERM = Color(230/255.0,230/255.0,30/255.0)
const OFF_FILL_ICON = Color(140/255.0,20/255.0, 20/255.0)
const ON_FILL_ICON = Color(240/255.0, 10/255.0, 10/255.0)

func _ready():
	term1.self_modulate = (OFF_FILL_TERM)
	term2.self_modulate = (OFF_FILL_TERM)
	termOut.self_modulate = (OFF_FILL_TERM)
	base.self_modulate = (FILL_BASE)
	icon.self_modulate = OFF_FILL_ICON
	
func updateTerm1(isActive : bool):
	if isActive and not terminal1Active:
		terminal1Active = true
		term1.self_modulate = ON_FILL_TERM
		checkOutput()
	elif not isActive and terminal1Active:
		terminal1Active = false
		term1.self_modulate = OFF_FILL_TERM
		checkOutput()
		
func updateTerm2(isActive : bool):
	if isActive and not terminal2Active:
		terminal2Active = true
		term2.self_modulate = ON_FILL_TERM
		checkOutput()
	elif not isActive and terminal2Active:
		terminal2Active = false
		term2.self_modulate = OFF_FILL_TERM
		checkOutput()
		
func checkOutput():
	if terminal1Active and terminal2Active and not outputActive:
		outputActive = true
		termOut.self_modulate = ON_FILL_TERM
		icon.self_modulate = ON_FILL_ICON
		#base.self_modulate = ON_FILL_BASE
	elif (not terminal1Active or not terminal2Active) and outputActive:
		outputActive = false
		termOut.self_modulate = OFF_FILL_TERM
		icon.self_modulate = OFF_FILL_ICON
		#base.self_modulate = OFF_FILL_BASE
	
