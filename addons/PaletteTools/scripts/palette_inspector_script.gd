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
	for color in my_plugin.get_editor_interface().get_editor_settings().get_project_metadata("color_picker", "presets"):
		col_picker.add_preset(color)
	
	editor_inspector = my_plugin.get_editor_interface().get_inspector()
#	editor_inspector.resource_selected.connect(resource_select_post)
	
	

func _can_handle(object):
	# We support all objects in this example.
	if object is Resource:
		# editor_inspector.resource_selected.emit(object, true)
		var prop = custom_palette_property.new(my_picker, object)
		for property in object.get_property_list():
			if "color" in property.name:
				prop.resource_selected.emit(property.name, object)
		#prop.resource_selected.emit("font_color", object)
		return false
	return true

#func resource_select_post(path, resource):
#	prints(path, resource)


func _parse_property(object, type, name, hint_type, hint_string, usage_flags, wide):
	#print(type)
	if type == TYPE_COLOR:
		#print("color")
		# Create an instance of the custom property editor and register
		# it to a specific property path.
		var prop = custom_palette_property.new(my_picker, object, name)
		# prop.custom_palette = custom_palette_picker
		add_property_editor(name, prop)
		# Inform the editor to remove the default property editor for
		# this property type.
		return true
	else:
		return false
		
#func _parse_end(object: Object):
#	print(object)
#
#func _parse_category(object, category):
#	prints(object, category)

func load_palettes():
#	my_palettes.clear()
#	config.load(config_path)
#	var json = JSON.new()
#	if config.has_section("color_picker"):
#		for sec in config.get_section_keys("color_picker"):
#			my_palettes.append(json.parse_string(config.get_value("color_picker", sec)))
#
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

