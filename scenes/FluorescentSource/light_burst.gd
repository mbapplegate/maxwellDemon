extends Node2D

@onready var burst = $CPUParticles2D

func burstGo(positionGlobal:Vector2, particleColor:Vector3):
	burst.color = Color(particleColor[0],particleColor[1],particleColor[2])
	burst.global_position = positionGlobal
	burst.emitting = true
