extends Node2D

signal snake_dead

onready var colorRect = $ColorRect

func _on_Hurtbox_area_entered(_area):
	emit_signal("snake_dead")
	
func setColor(newcolor):
	colorRect.color = newcolor

func getColor():
	return(colorRect.color)
