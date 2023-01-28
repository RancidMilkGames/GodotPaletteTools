@tool
extends EditorPlugin

var dock
var inspector_palette_plugin
var script_editor


func _enter_tree():
	dock = preload("res://addons/PaletteTools/Scenes/palette_tools.tscn").instantiate()
	dock.get_child(0).my_plugin = self
	add_control_to_dock(DOCK_SLOT_RIGHT_UL, dock)
	
	inspector_palette_plugin = preload("res://addons/PaletteTools/Scripts/palette_inspector_script.gd").new(self)
	add_inspector_plugin(inspector_palette_plugin)
	
	if get_editor_interface().get_selection().get_selected_nodes().size() > 0:
		get_editor_interface().edit_node(get_editor_interface().get_selection().get_selected_nodes()[0])


func _exit_tree():
	remove_control_from_docks(dock)
	dock.free()
	
	remove_inspector_plugin(inspector_palette_plugin)

func _get_plugin_icon():
	return preload("res://addons/PaletteTools/icon.png")


func _get_plugin_name():
	return "Palette Tools"
