tool
class_name ReplaceColorRes
extends Resource

var colors := [] setget set_colors

func set_colors(p_value):
	colors = p_value
	var c = preload("replaceColorObj.gd")
	for i in colors.size():
		if !colors[i] || !colors[i] is c:
			colors[i] = c.new()
	emit_signal("changed")

func _get_property_list():
	var ret = []
	ret.append({"name":"colors", "type":TYPE_ARRAY, "hint_string":str(TYPE_OBJECT) + "/" + str(PROPERTY_HINT_RESOURCE_TYPE) + ":ReplaceColorObj", "usage":PROPERTY_USAGE_DEFAULT})
	return ret
