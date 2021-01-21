tool
extends EditorInspectorPlugin

func can_handle(p_object):
	return true

func parse_property(p_object, p_type, p_path, p_hint, p_hintText, p_usage):
	if p_type == TYPE_OBJECT && p_hint & PROPERTY_HINT_RESOURCE_TYPE && p_hintText == "ReplaceColorObj":
		add_property_editor(p_path, preload("replaceColorObjProperty.gd").new())
		return true
	else:
		return false
