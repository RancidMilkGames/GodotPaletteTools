@tool
extends EditorPlugin

const ColorPalette := preload("res://addons/PaletteTools/Scripts/palette_tool.gd")
const CustomPickerPlugin := preload("res://addons/PaletteTools/Scripts/palette_inspector_script.gd")

var dock: Control
var inspector_palette_plugin: CustomPickerPlugin
var colors: ColorPalette
var config := ConfigFile.new()
var config_path := "res://addons/PaletteTools/color_presets.cfg"


func _enter_tree() -> void:
	dock = preload("res://addons/PaletteTools/Scenes/palette_tools.tscn").instantiate() as Control
	colors = dock.get_child(0) as ColorPalette
	inspector_palette_plugin = preload("res://addons/PaletteTools/Scripts/palette_inspector_script.gd").new(self)

	colors.my_plugin = self
	add_control_to_dock(DOCK_SLOT_RIGHT_UL, dock)
	
	config.load(config_path)
	var json := JSON.new()
	if config.has_section("settings"):
		var toggled: bool = config.get_value("settings", "custom_palette_on")
		if toggled:
			toggle_custom_picker(toggled)
		colors.custom_picker_check_box.button_pressed = toggled
	else:
		config.set_value("settings", "custom_palette_on", false)
		
	inspector_palette_plugin.load_palettes()
	inspector_palette_plugin.initial_palette()

func toggle_custom_picker(state: bool):
	config.set_value("settings", "custom_palette_on", state)
	config.save(config_path)
	if state:
		add_inspector_plugin(inspector_palette_plugin)
	else:
		remove_inspector_plugin(inspector_palette_plugin)


func _exit_tree() -> void:
	if dock:
		remove_control_from_docks(dock)
		dock.free()
	
	if is_instance_valid(inspector_palette_plugin) and config.get_value("settings", "custom_palette_on"):
		remove_inspector_plugin(inspector_palette_plugin)


func _get_plugin_icon() -> Texture2D:
	return preload("res://addons/PaletteTools/icon.png")


func _get_plugin_name() -> String:
	return "Palette Tools"
