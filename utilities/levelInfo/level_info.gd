extends Node

const WIRE_OFF_COLOR = Color(10/255.0,10/255.0,10/255.0)
const WIRE_ON_COLOR = Color(240/255.0,240/255.0,60/255.0)

signal imagingModeChanged(val)

var LevelDictionary = {
	"MainMenu"    : {"Path" : "res://utilities/mainMenu/main_menu.tscn",           "Title" : "Main Menu",      "Section" : "Menus"} ,
	"LevelSelect" : {"Path" : "res://utilities/levelSelector/level_selector.tscn", "Title" : "Select Level",   "Section" : "Menus"},
	"Manager"     : {"Path" : "res://utilities/gameManager/game_manager.tscn",     "Title" : "Game Manager",   "Section" : "Menus"},
	"TestWorld"   : {"Path" : "res://worlds/test_world.tscn",                      "Title" : "Debug",          "Section" : "Debug"},
	"Level001"    : {"Path" : "res://worlds/Level001/level_001.tscn",              "Title" : "Energize!",      "Section" : "Tutorials"},
	"EnergizeLesson" : {"Path" : "res://lessons/energize/energize_lesson.tscn",    "Title" : "Energize Lesson", "Section" : "Lessons"},
	"Level002"    : {"Path" : "res://worlds/Level002/level_002.tscn",              "Title" : "Rotate",         "Section" : "Tutorials"},
	"RotateLesson" : {"Path" : "res://lessons/rotate/rotate_lesson.tscn",          "Title" : "Rotate Lesson",  "Section" : "Lessons"},
	"Level003"    : {"Path" : "res://worlds/Level003/level_003.tscn",              "Title" : "Push",           "Section" : "Tutorials"},
	"PushLesson"  : {"Path" : "res://lessons/push/push_lesson.tscn",               "Title" : "Push Lesson",    "Section" : "Lessons"},
	"Level004"    : {"Path" : "res://worlds/Level004/level_004.tscn",              "Title" : "Pull",           "Section" : "Tutorials"},
	"DetectorLesson" : {"Path" : "res://lessons/detector/detector_lesson.tscn",    "Title" : "Detector Lesson", "Section" : "Lessons"},
	"Level005"    : {"Path" : "res://worlds/Level005/level_005.tscn",              "Title" : "Multiple Goals", "Section" : "Tutorials"},
	"MeterLesson" : {"Path" : "res://lessons/meter/meter_lesson.tscn",             "Title" : "Meter Lesson",   "Section" : "Lessons"},
	"DigitalMeterLesson" : {"Path" : "res://lessons/digitalMeter/digital_meter_lesson.tscn", "Title" : "Digital Meter Lesson", "Section" : "Lessons"},
	"Level006"    : {"Path" : "res://worlds/Level006/level_006.tscn",              "Title" : "Mirrors",        "Section" : "Tutorials"},
	"MirrorLesson": {"Path" : "res://lessons/mirror/mirror_lesson.tscn",           "Title" : "Mirror Lesson",  "Section" : "Lessons"},
	"Level007"    : {"Path" : "res://worlds/Level007/level_007.tscn",              "Title" : "Focus",          "Section" : "Tutorials"},
	"ConvexLensLesson"  : {"Path" : "res://lessons/convexLens/convex_lens_lesson.tscn", "Title" : "Convex Lens Lesson", "Section" : "Lessons"},
	"Level007b"   : {"Path" : "res://worlds/Level007b_negLens/level_007b_negative_lens.tscn", "Title" : "Diverging Lens", "Section" : "Lenses and Mirrors"},
	"ConcaveLensLesson" : {"Path" : "res://lessons/concaveLens/concave_lens_lesson.tscn", "Title" : "Concave Lens Lesson", "Section" : "Lessons"},
	"Level008"    : {"Path" : "res://worlds/Level008/level_008.tscn",              "Title" : "Collimation",    "Section" : "Lenses and Mirrors"},
	"CollimationLesson" : {"Path" : "res://lessons/collimation/collimation_lesson.tscn", "Title" : "Collimation Lesson", "Section" : "Lessons"},
	"Level009"    : {"Path" : "res://worlds/Level009/level_009.tscn",              "Title" : "Expand",         "Section" : "Lenses and Mirrors"},
	"BeamExpanderLesson" : {"Path" : "res://lessons/beamExpanderKep/beam_expander_lesson.tscn", "Title" : "Beam Expander Lesson", "Section" : "Lessons"},
	"Level009b"   : {"Path" : "res://worlds/Level009b_negBeamExp/level_009b.tscn", "Title" : "Expand Again",         "Section" : "Lenses and Mirrors"},
	"BeamExpanderLesson2" : {"Path" : "res://lessons/beamExpanderGal/beam_expander_gal_lesson.tscn", "Title" : "Galilan Beam Expander", "Section" : "Lessons"},
	"Level010"    : {"Path" : "res://worlds/Level010/level_010.tscn",              "Title" : "Image",          "Section" : "Debug"},
	"Level011"    : {"Path" : "res://worlds/Level011/level_011.tscn",              "Title" : "Parabolic Mirror","Section" : "Lenses and Mirrors"},
	"ParabolicMirrorLesson" : {"Path" : "res://lessons/parabolicMirror/parabolic_mirror_lesson.tscn", "Title" : "Parabolic Mirror Lesson","Section" : "Lessons"},
	"Level012Filters" : {"Path" : "res://worlds/Level012_Filters/level_012_filters.tscn", "Title" : "Filters", "Section" : "Colors"}
}

var SectionOrdering = ["Menus", "Tutorials", "Lenses and Mirrors", "Colors", "Lessons", "Debug"]

var GameFlow = {
	"Level001"              : "Level002",
	"Level002"              : "Level003",
	"Level003"              : "Level004",
	"Level004"              : "DetectorLesson",
	"DetectorLesson"        : "Level005",
	"Level005"              : "DigitalMeterLesson",
	"DigitalMeterLesson"    : "Level006",
	"Level006"              : "MirrorLesson",
	"MirrorLesson"          : "Level007",
	"Level007"              : "ConvexLensLesson",
	"ConvexLensLesson"      : "Level007b",
	"Level007b"             : "ConcaveLensLesson",
	"ConcaveLensLesson"     : "Level008",
	"Level008"              : "CollimationLesson",
	"CollimationLesson"     : "Level009",
	"Level009"              : "BeamExpanderLesson",
	"BeamExpanderLesson"    : "Level009b",
	"Level009b"             : "BeamExpanderLesson2",
	"BeamExpanderLesson2"   : "Level011",
	"Level011"              : "ParabolicMirrorLesson",
	"ParabolicMirrorLesson" : "MainMenu"
	
}
var inImagingMode: bool = false

func _input(event):
	if event.is_action_pressed("imageMode"):
		inImagingMode = !inImagingMode
		imagingModeChanged.emit(inImagingMode)
