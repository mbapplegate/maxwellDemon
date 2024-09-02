extends Node

const WIRE_OFF_COLOR = Color(10/255.0,10/255.0,10/255.0)
const WIRE_ON_COLOR = Color(240/255.0,240/255.0,60/255.0)

signal imagingModeChanged(val)

var LevelDictionary = {
	"MainMenu"    : {"Path" : "res://utilities/mainMenu/main_menu.tscn",           "Title" : "Main Menu",      "Section" : "Menus"} ,
	"LevelSelect" : {"Path" : "res://utilities/levelSelector/level_selector.tscn", "Title" : "Select Level",   "Section" : "Menus"},
	"Manager"     : {"Path" : "res://utilities/gameManager/game_manager.tscn",     "Title" : "Game Manager",   "Section" : "Menus"},
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
	"DigitalMeterLesson" : {"Path" : "res://lessons/digitalMeter/digital_meter_lesson.tscn", "Title" : "Digital Meter Lesson", "Section" : "Lessons"},
	"Level006"    : {"Path" : "res://worlds/Level006/level_006.tscn",              "Title" : "Mirrors",        "Section" : "Lenses and Mirrors"},
	"MirrorLesson": {"Path" : "res://lessons/mirror/mirror_lesson.tscn",           "Title" : "Mirror Lesson",  "Section" : "Lessons"},
	"Level007"    : {"Path" : "res://worlds/Level007/level_007.tscn",              "Title" : "Focus",          "Section" : "Lenses and Mirrors"},
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
	"Level012Filters" : {"Path" : "res://worlds/Level012_Filters/level_012_filters.tscn", "Title" : "Filters", "Section" : "Colors"},
	"LevelEquiPrism" : {"Path" : "res://worlds/equilateralPrism/level_equilateral_prism.tscn", "Title" : "Triangular Prism", "Section" : "Dispersion"},
	"LevelEquiPrism2" : {"Path" : "res://worlds/equilateralPrism2/level_equilateral_prism_2.tscn", "Title" : "Fine Control", "Section" : "Dispersion"},
	"LevelEquiPrism3" : {"Path" : "res://worlds/equilateralPrism3/level_equilateral_prism_3.tscn", "Title" : "Source Spectra", "Section" : "Dispersion"},
	"LevelPrismRecombine" :{"Path": "res://worlds/prismRecombine/level_prism_recombine.tscn", "Title" : "Newton's Prism Experiment", "Section" : "Dispersion"},
	"TriangularPrismLesson" : {"Path": "res://lessons/prism/triangular_prism_lesson.tscn", "Title" : "Prism Lesson", "Section":"Lessons"},
	"FilterLesson" : {"Path" : "res://lessons/filtersAbs/filter_lesson.tscn", "Title" : "Filter Lesson", "Section":"Lessons"},
	"ComingSoon"   : {"Path" : "res://utilities/comingSoon/coming_soon.tscn", "Title" : "Coming Soon", "Section" : "Menus"}
}

var SectionOrdering = ["Menus", "Tutorial", "Lenses and Mirrors","Dispersion", "Colors", "Lessons", "Debug"]

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
	"ParabolicMirrorLesson" : "LevelEquiPrism",
	"LevelEquiPrism"        : "TriangularPrismLesson",
	"TriangularPrismLesson" : "LevelEquiPrism2",
	"LevelEquiPrism2"       : "FilterLesson",
	"FilterLesson"          : "LevelEquiPrism3",
	"LevelEquiPrism3"       : "LevelPrismRecombine",
	"LevelPrismRecombine"   : "ComingSoon",
	"ComingSoon"            : "MainMenu"
	
}
var inImagingMode: bool = false

func _input(event):
	if event.is_action_pressed("imageMode"):
		inImagingMode = !inImagingMode
		imagingModeChanged.emit(inImagingMode)
