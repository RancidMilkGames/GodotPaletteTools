@tool
extends EditorPlugin

var dock
var inspector_palette_plugin


func _enter_tree():
	dock = preload("res://addons/PaletteTools/Scenes/palette_tools.tscn").instantiate()
	dock.get_child(0).my_plugin = self
	add_control_to_dock(DOCK_SLOT_RIGHT_UL, dock)
	
	inspector_palette_plugin = preload("res://addons/PaletteTools/Scripts/palette_inspector_script.gd").new(self)
	#inspector_palette_plugin.my_plugin = self
	add_inspector_plugin(inspector_palette_plugin)


func _exit_tree():
	remove_control_from_docks(dock)
	dock.free()
	
	remove_inspector_plugin(inspector_palette_plugin)
	# inspector_palette_plugin.free()

func _get_plugin_icon():
	return preload("res://addons/PaletteTools/icon.png")


func _get_plugin_name():
	return "Palette Tools"
