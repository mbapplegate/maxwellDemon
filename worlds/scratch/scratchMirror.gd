extends Node2D

func _ready():
	for child in get_children():
		if child is pushableObject:
			child.initialize()
