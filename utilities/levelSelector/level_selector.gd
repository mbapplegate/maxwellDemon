extends Node2D

@onready var label = $Label
@onready var mainContainer = $VBoxContainer

signal nextScene(sceneAlias)

const TEXT_COLOR = Color(0.2,0.2,0.2,1.0)
const TEXT_TRANS = Color(0.2,0.2,0.2,0.0)
const MAX_BUTTONS_PER_ROW : int = 10

var orgChart = {}
var aliasChart = {}

func _ready():
	for key in LevelInfo.GameFlow:
		var thisSection = LevelInfo.LevelDictionary[key]["Section"]
		if not orgChart.has(thisSection):
			orgChart[thisSection] = 1
			aliasChart[thisSection] = []
			aliasChart[thisSection].append(key)
		
		else:
			orgChart[thisSection] += 1
			aliasChart[thisSection].append(key)
			#numLevelsPerSection[sections.bsearch(LevelInfo.LevelDictionary[key]["Section"])] += 1
	#print(orgChart)	
	label.self_modulate = TEXT_COLOR
	var somethingHasFocus = false
	for key in LevelInfo.SectionOrdering:
		if orgChart.has(key):
			var thisLabel = Label.new()
			thisLabel.set("theme_override_font_sizes/font_size", 32)
			thisLabel.text = key
			mainContainer.add_child(thisLabel)
			var levelBox = HBoxContainer.new()
			mainContainer.add_child(levelBox)
			var currentButtonsInRow = 0
			for levelNum in range(orgChart[key]):
				var thisButton = LevelSelectButton.new()
				thisButton.text = "%02d" % (levelNum+1)
				thisButton.levelAlias = aliasChart[key][levelNum]
				thisButton.custom_minimum_size = Vector2(96,96)
				levelBox.add_child(thisButton)
				if not somethingHasFocus:
						thisButton.grab_focus()
						somethingHasFocus = true
						label.text =  LevelInfo.LevelDictionary[thisButton.levelAlias].Title
				thisButton.connect("pressed",buttonPressed.bind(thisButton.levelAlias))
				thisButton.connect("focus_entered",buttonFocusEntered.bind(thisButton.levelAlias))
				
				currentButtonsInRow += 1
				if currentButtonsInRow > MAX_BUTTONS_PER_ROW:
					currentButtonsInRow = 0
					levelBox = HBoxContainer.new()
					mainContainer.add_child(levelBox)
	$Label.reparent(mainContainer)

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
	
