@tool
extends EditorPlugin

var dock


func _enter_tree():
	dock = preload("res://addons/PaletteTools/Scenes/godot_colors.tscn").instantiate()
	dock.get_child(0).my_plugin = self
	add_control_to_dock(DOCK_SLOT_RIGHT_UL, dock)


func _exit_tree():
	remove_control_from_docks(dock)
	dock.free()

func _get_plugin_icon():
	return preload("res://addons/PaletteTools/icon.png")


func _get_plugin_name():
	return "Palette Tools"
