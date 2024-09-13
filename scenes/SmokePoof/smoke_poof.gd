extends Node2D

func make_poof(poofLoc:Vector2):
	self.position = poofLoc
	$CPUParticles2D.emitting = true
