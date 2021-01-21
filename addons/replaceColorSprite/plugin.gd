tool
extends EditorPlugin

var inspectorPlugin

func _enter_tree():
	inspectorPlugin = preload("replaceColorInspectorPlugin.gd").new()
	add_inspector_plugin(inspectorPlugin)
	add_custom_type("ReplaceColorSprite", "Sprite", preload("replaceColorSprite.gd"), get_editor_interface().get_base_control().get_icon("Sprite", "EditorIcons"))


func _exit_tree():
	remove_inspector_plugin(inspectorPlugin)
	inspectorPlugin = null
	remove_custom_type("ReplaceColorSprite")
