extends Node2D

signal food_eaten

onready var colorRect = $ColorRect

func _on_Hurtbox_area_entered(_area):
	emit_signal("food_eaten")
	
func setColor(newcolor: Color):
	colorRect.color = newcolor

func getColor():
	return(colorRect.color)

