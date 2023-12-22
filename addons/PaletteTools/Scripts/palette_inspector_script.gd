extends EditorInspectorPlugin

const custom_palette_property := preload("res://addons/PaletteTools/Scripts/custom_property.gd")
const CustomColorPicker := preload("res://addons/PaletteTools/Scripts/custom_picker.gd")
const PalettePlugin := preload("res://addons/PaletteTools/palette_tools.gd")
#const custom_palette_picker: PackedScene #= pre

var my_picker: CustomColorPicker
var my_plugin: PalettePlugin
var saved_palettes: ItemList
var editor_inspector: EditorInspector


func _init(plugin: PalettePlugin) -> void:
	#custom_palette_picker = load("res://addons/PaletteTools/Scenes/custom_picker.tscn")
	my_plugin = plugin
	my_picker = load("res://addons/PaletteTools/Scenes/custom_picker.tscn").instantiate() as CustomColorPicker
	my_plugin.dock.add_child(my_picker)

	my_plugin.colors.palette_list_updated.connect(load_palettes)
	saved_palettes = my_picker.saved_palettes
	saved_palettes.item_activated.connect(set_palette)
	my_picker.apply_palette_button.pressed.connect(set_palette.bind(-1))

	editor_inspector = my_plugin.get_editor_interface().get_inspector()


func initial_palette():
	var col_picker := my_picker.color_picker as ColorPicker
	var editor_settings := my_plugin.get_editor_interface().get_editor_settings()
	var preset_settings := editor_settings.get_project_metadata("color_picker", "presets", [])
	if preset_settings:
		for color: String in preset_settings:
			col_picker.add_preset(Color(color))


func _can_handle(object: Object) -> bool:
	if object is Resource:
		var prop := custom_palette_property.new(my_picker, object)
		for property: Dictionary in object.get_property_list():
			if "color" in property.name:
				prop.resource_selected.emit(property.name, object)
		return false
	return true


func _parse_property(object: Object, type: Variant.Type, name: String, hint_type: PropertyHint, hint_string: String, usage_flags: PropertyHint, wide: bool) -> bool:
	if type == TYPE_COLOR:
		var prop := custom_palette_property.new(my_picker, object, name)
		add_property_editor(name, prop)
		return true
	else:
		return false


func load_palettes() -> void:
	if my_plugin.colors.my_palettes.size() > 0:
		saved_palettes.clear()
		for p in my_plugin.colors.my_palettes:
			saved_palettes.add_item(p.name)
	else:
		saved_palettes.clear()
		saved_palettes.add_item("No Palettes")


func set_palette(palette_num: int) -> void:
	if palette_num == -1 and saved_palettes.get_selected_items().size() > 0:
		palette_num = saved_palettes.get_selected_items()[0]
	var col_picker: ColorPicker = my_picker.color_picker
	for color: Color in col_picker.get_presets():
		col_picker.erase_preset(color)
	for color: Color in my_plugin.colors.my_palettes[palette_num].colors:
		col_picker.add_preset(color)
