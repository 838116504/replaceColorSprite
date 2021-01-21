tool
extends EditorProperty

var updating = false
var hbox = HBoxContainer.new()
var fromBtn = ColorPickerButton.new()
var midLabel = Label.new()
var toBtn = ColorPickerButton.new()
var target = null

func _init():
	fromBtn.size_flags_horizontal = SIZE_EXPAND_FILL
	var emptyStyle = StyleBoxEmpty.new()
	fromBtn.add_stylebox_override("normal", emptyStyle)
	fromBtn.add_stylebox_override("hover", emptyStyle)
	fromBtn.add_stylebox_override("pressed", emptyStyle)
	fromBtn.connect("color_changed", self, "_on_fromBtn_color_changed")
	fromBtn.connect("popup_closed", self, "_on_fromBtn_popup_closed")
	toBtn.size_flags_horizontal = SIZE_EXPAND_FILL
	toBtn.add_stylebox_override("normal", emptyStyle)
	toBtn.add_stylebox_override("hover", emptyStyle)
	toBtn.add_stylebox_override("pressed", emptyStyle)
	toBtn.connect("color_changed", self, "_on_toBtn_color_changed")
	toBtn.connect("popup_closed", self, "_on_toBtn_popup_closed")
	
	hbox.add_child(fromBtn)
	midLabel.text = ">"
	hbox.add_child(midLabel)
	hbox.add_child(toBtn)
	hbox.size_flags_horizontal = SIZE_EXPAND_FILL
	add_child(hbox)

func _on_fromBtn_color_changed(p_color:Color):
	if updating:
		return
	var obj = get_edited_object()[get_edited_property()]
	if p_color == obj.fromColor:
		return
	obj.fromColor = p_color
#	emit_changed(get_edited_property(), obj)


func _on_toBtn_color_changed(p_color:Color):
	if updating:
		return
	var obj = get_edited_object()[get_edited_property()]
	if p_color == obj.toColor:
		return
	obj.toColor = p_color
#	emit_changed(get_edited_property(), obj)

func _on_fromBtn_popup_closed():
	var obj = get_edited_object()[get_edited_property()]
	if fromBtn.get_picker().color == obj.fromColor:
		return
	obj.fromColor = fromBtn.get_picker().color
#	emit_changed(get_edited_property(), obj)

func _on_toBtn_popup_closed():
	var obj = get_edited_object()[get_edited_property()]
	if toBtn.get_picker().color == obj.toColor:
		return
	obj.toColor = toBtn.get_picker().color
#	emit_changed(get_edited_property(), obj)

func update_property():
	var obj = get_edited_object()[get_edited_property()]
	if obj == null:
		obj = preload("replaceColorObj.gd").new()
		emit_changed(get_edited_property(), obj)
	if target != obj:
		if target:
			target.disconnect("changed", self, "_on_target_changed")
		target = obj
		target.connect("changed", self, "_on_target_changed")
	_on_target_changed()

func _on_target_changed():
	updating = true
	fromBtn.color = target.fromColor
	toBtn.color = target.toColor
	updating = false
