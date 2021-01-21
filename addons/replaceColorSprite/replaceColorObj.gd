tool
class_name ReplaceColorObj
extends Resource

export var fromColor:Color = Color(0.0, 0.0, 0.0, 1.0) setget set_from_color
export var toColor:Color = Color(0.0, 0.0, 0.0, 1.0) setget set_to_color

func set_from_color(p_value:Color):
	if fromColor == p_value:
		return
	
	fromColor = p_value
	emit_signal("changed")

func set_to_color(p_value:Color):
	if toColor == p_value:
		return
	
	toColor = p_value
	emit_signal("changed")
