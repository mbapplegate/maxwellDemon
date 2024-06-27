extends Node2D

@onready var label = $Label
@onready var levelButton = preload("res://utilities/levelSelectButton/level_select_button.tscn")
signal nextScene(sceneAlias)

const TEXT_COLOR = Color(0.2,0.2,0.2,1.0)
const TEXT_TRANS = Color(0.2,0.2,0.2,0.0)

var orgChart = {}

func _ready():
	for key in LevelInfo.GameFlow:
		var thisSection = LevelInfo.LevelDictionary[key]["Section"]
		if not orgChart.has(thisSection):
			orgChart[thisSection] = 1
		else:
			orgChart[thisSection] += 1
			#numLevelsPerSection[sections.bsearch(LevelInfo.LevelDictionary[key]["Section"])] += 1
	print(orgChart)
	label.self_modulate = TEXT_COLOR
	$HBoxContainer/Level01.grab_focus()
	var firstAlias = $HBoxContainer/Level01.levelAlias
	label.text =  LevelInfo.LevelDictionary[firstAlias].Title
	for child in $HBoxContainer.get_children():
		if child is LevelSelectButton:
			child.connect("pressed",buttonPressed.bind(child.levelAlias))
			child.connect("focus_entered",buttonFocusEntered.bind(child.levelAlias))

func buttonFocusEntered(levelAlias):
	if label.self_modulate.a > 0:
		var fadeOut = get_tree().create_tween()
		fadeOut.tween_property(label,"self_modulate",TEXT_TRANS,0.25)
		await fadeOut.finished
		
	label.text = LevelInfo.LevelDictionary[levelAlias].Title
	var fadeIn = get_tree().create_tween()
	fadeIn.tween_property(label,"self_modulate",TEXT_COLOR,0.25)
	await fadeIn.finished
	
func buttonPressed(levelAlias):
	nextScene.emit(levelAlias)
	
