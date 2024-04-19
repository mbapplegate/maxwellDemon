extends Node

const WIRE_OFF_COLOR = Color(10/255.0,10/255.0,10/255.0)
const WIRE_ON_COLOR = Color(240/255.0,240/255.0,60/255.0)

var LevelDictionary = {
	"MainMenu"    : {"Path" : "res://utilities/mainMenu/main_menu.tscn",           "Title" : "Main Menu",      "Section" : "Menu"} ,
	"LevelSelect" : {"Path" : "res://utilities/levelSelector/level_selector.tscn", "Title" : "Select Level",   "Section" : "Menu"},
	"Manager"     : {"Path" : "res://utilities/gameManager/game_manager.tscn",     "Title" : "Game Manager",   "Section" : "Menu"},
	"TestWorld"   : {"Path" : "res://worlds/test_world.tscn",                      "Title" : "Debug",          "Section" : "Debug"},
	"Level001"    : {"Path" : "res://worlds/Level001/level_001.tscn",              "Title" : "Energize!",      "Section" : "Tutorial"},
	"Level002"    : {"Path" : "res://worlds/Level002/level_002.tscn",              "Title" : "Rotate",         "Section" : "Tutorial"},
	"Level003"    : {"Path" : "res://worlds/Level003/level_003.tscn",              "Title" : "Push",           "Section" : "Tutorial"},
	"Level004"    : {"Path" : "res://worlds/Level004/level_004.tscn",              "Title" : "Pull",           "Section" : "Tutorial"},
	"Level005"    : {"Path" : "res://worlds/Level005/level_005.tscn",              "Title" : "Multiple Goals", "Section" : "Tutorial"},
	"Level006"    : {"Path" : "res://worlds/Level006/level_006.tscn",              "Title" : "Mirrors",        "Section" : "Tutorial"},
	"Level007"    : {"Path" : "res://worlds/Level007/level_007.tscn",              "Title" : "Focus",          "Section" : "Tutorial"}
}
