extends Node

const WIRE_OFF_COLOR = Color(10/255.0,10/255.0,10/255.0)
const WIRE_ON_COLOR = Color(240/255.0,240/255.0,60/255.0)

signal imagingModeChanged(val)

var LevelDictionary = {
	"MainMenu"    : {"Path" : "res://utilities/mainMenu/main_menu.tscn",           "Title" : "Main Menu",      "Section" : "Menu"} ,
	"LevelSelect" : {"Path" : "res://utilities/levelSelector/level_selector.tscn", "Title" : "Select Level",   "Section" : "Menu"},
	"Manager"     : {"Path" : "res://utilities/gameManager/game_manager.tscn",     "Title" : "Game Manager",   "Section" : "Menu"},
	"TestWorld"   : {"Path" : "res://worlds/test_world.tscn",                      "Title" : "Debug",          "Section" : "Debug"},
	"Level001"    : {"Path" : "res://worlds/Level001/level_001.tscn",              "Title" : "Energize!",      "Section" : "Tutorial"},
	"EnergizeLesson" : {"Path" : "res://lessons/energize/energize_lesson.tscn",    "Title" : "Energize Lesson", "Section" : "Lessons"},
	"Level002"    : {"Path" : "res://worlds/Level002/level_002.tscn",              "Title" : "Rotate",         "Section" : "Tutorial"},
	"RotateLesson" : {"Path" : "res://lessons/rotate/rotate_lesson.tscn",          "Title" : "Rotate Lesson",  "Section" : "Lessons"},
	"Level003"    : {"Path" : "res://worlds/Level003/level_003.tscn",              "Title" : "Push",           "Section" : "Tutorial"},
	"PushLesson"  : {"Path" : "res://lessons/push/push_lesson.tscn",               "Title" : "Push Lesson",    "Section" : "Lessons"},
	"Level004"    : {"Path" : "res://worlds/Level004/level_004.tscn",              "Title" : "Pull",           "Section" : "Tutorial"},
	"DetectorLesson" : {"Path" : "res://lessons/detector/detector_lesson.tscn",    "Title" : "Detector Lesson", "Section" : "Lessons"},
	"Level005"    : {"Path" : "res://worlds/Level005/level_005.tscn",              "Title" : "Multiple Goals", "Section" : "Tutorial"},
	"MeterLesson" : {"Path" : "res://lessons/meter/meter_lesson.tscn",             "Title" : "Meter Lesson",   "Section" : "Lessons"},
	"Level006"    : {"Path" : "res://worlds/Level006/level_006.tscn",              "Title" : "Mirrors",        "Section" : "Tutorial"},
	"MirrorLesson": {"Path" : "res://lessons/mirror/mirror_lesson.tscn",           "Title" : "Mirror Lesson",  "Section" : "Lessons"},
	"Level007"    : {"Path" : "res://worlds/Level007/level_007.tscn",              "Title" : "Focus",          "Section" : "Tutorial"},
	"ConvexLensLesson"  : {"Path" : "res://lessons/convexLens/convex_lens_lesson.tscn", "Title" : "Convex Lens Lesson", "Section" : "Lessons"},
	"Level008"    : {"Path" : "res://worlds/Level008/level_008.tscn",              "Title" : "Collimation",    "Section" : "LensesAndMirrors"},
	"CollimationLesson" : {"Path" : "res://lessons/collimation/collimation_lesson.tscn", "Title" : "Collimation Lesson", "Section" : "Lessons"},
	"Level009"    : {"Path" : "res://worlds/Level009/level_009.tscn",              "Title" : "Expand",         "Section" : "LensesAndMirrors"},
	"BeamExpanderLesson" : {},
	"Level010"    : {"Path" : "res://worlds/Level010/level_010.tscn",              "Title" : "Image",          "Section" : "Debug"},
	"Level011"    : {"Path" : "res://worlds/Level011/level_011.tscn",              "Title" : "Parabolic Mirror","Section" : "LensesAndMirrors"}
}

var inImagingMode: bool = false

func _input(event):
	if event.is_action_pressed("imageMode"):
		inImagingMode = !inImagingMode
		imagingModeChanged.emit(inImagingMode)
