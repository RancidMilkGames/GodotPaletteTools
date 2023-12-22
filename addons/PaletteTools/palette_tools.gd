@tool
extends EditorPlugin

const ColorPalette := preload("res://addons/PaletteTools/Scripts/palette_tool.gd")
const CustomPickerPlugin := preload("res://addons/PaletteTools/Scripts/palette_inspector_script.gd")

var dock: Control
var inspector_palette_plugin: CustomPickerPlugin
var colors: ColorPalette
var config := ConfigFile.new()
var config_path := "res://addons/PaletteTools/color_presets.cfg"
var max_first_load_tries := 100


func _enter_tree() -> void:
	## load configurations if they exist
	var err := config.load(config_path)

	## If configurations don't exist, it's probably the first plugin load.
	## If installed from the asset library, the plugin is automatically activated.
	## We want to wait for textures to be imported before loading the plugin for this reason.
	## Not doing so will procude log errors and require a project restart
	## before the plugin will work.
	if err != OK:
		## Bool to break out of a loop from sub loop
		var found_import := false
		## Search for first sign that the import has happened
		## Max attempt of 10 seconds(0.1 * 100)
		for try in max_first_load_tries:
			for file in DirAccess.get_files_at("res://addons/PaletteTools/Images/"):
				if ".import" in file:
					found_import = true
					break
			if found_import:
				break
			await get_tree().create_timer(.1).timeout
		if not found_import:
			## Test
			## Plugin will fail to load if this point is somehow reached.
			## Show error, stop load, and disable to prevent error spam before also failing.
			push_error(
				"Palette Tools failed to locate both configuration settings and imported textures. "
				+ "Turning the plugin on again or a project restart may fix this if you have not modified the plugin. "
				+ "Stopping plugin load and deactivating to prevent a less graceful failure. "
				+ "If you are modifying the plugin and running into this error, "
				+ "please edit res://addons/PaletteTools/palette_tools.gd to your needs."
			)
			abort_load()
			return

	dock = load("res://addons/PaletteTools/Scenes/palette_tools.tscn").instantiate() as Control
	colors = dock.get_node("Colors") as ColorPalette
	inspector_palette_plugin = load("res://addons/PaletteTools/Scripts/palette_inspector_script.gd").new(self)

	colors.my_plugin = self
	add_control_to_dock(DOCK_SLOT_RIGHT_UL, dock)

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
	return load("res://addons/PaletteTools/icon.png")


func _get_plugin_name() -> String:
	return "Palette Tools"


func abort_load():
	await get_tree().create_timer(.1).timeout
	get_editor_interface().set_plugin_enabled("PaletteTools", false)
