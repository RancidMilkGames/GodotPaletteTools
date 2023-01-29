extends EditorInspectorPlugin

var custom_palette_property = preload("res://addons/PaletteTools/Scripts/custom_property.gd")
var custom_palette_picker = load("res://addons/PaletteTools/Scenes/custom_picker.tscn") #.instantiate()
var my_picker
var my_plugin
var saved_palettes
var editor_inspector


func _init(plugin):
	my_plugin = plugin
	my_picker = custom_palette_picker.instantiate()
	my_plugin.dock.add_child(my_picker)
	
	my_plugin.dock.get_child(0).palette_list_updated.connect(load_palettes)
	saved_palettes = my_picker.saved_palettes #get_child(0).get_child(0).get_child(2)
	saved_palettes.item_activated.connect(set_palette)
	load_palettes()
	
	var col_picker = my_picker.get_child(0).get_child(0).get_child(0)
	var preset_settings = my_plugin.get_editor_interface().get_editor_settings().get_project_metadata("color_picker", "presets", Color.WHITE)
	if preset_settings is Array:
		for color in preset_settings:
			col_picker.add_preset(color)
	
	editor_inspector = my_plugin.get_editor_interface().get_inspector()


func _can_handle(object):
	if object is Resource:
		var prop = custom_palette_property.new(my_picker, object)
		for property in object.get_property_list():
			if "color" in property.name:
				prop.resource_selected.emit(property.name, object)
		return false
	return true


func _parse_property(object, type, name, hint_type, hint_string, usage_flags, wide):
	if type == TYPE_COLOR:
		var prop = custom_palette_property.new(my_picker, object, name)
		add_property_editor(name, prop)
		return true
	else:
		return false


func load_palettes():
	if my_plugin.dock.get_child(0).my_palettes.size() > 0:
		saved_palettes.clear()
		for p in my_plugin.dock.get_child(0).my_palettes:
			saved_palettes.add_item(p.Name)
	else:
		saved_palettes.clear()
		saved_palettes.add_item("No Palettes")


func set_palette(palette_num):
	var col_picker = my_picker.get_child(0).get_child(0).get_child(0)
	for color in col_picker.get_presets():
		col_picker.erase_preset(color)
	for color in my_plugin.dock.get_child(0).my_palettes[palette_num].Colors:
		col_picker.add_preset(color)

