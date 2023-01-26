extends EditorInspectorPlugin

var custom_palette_property = preload("res://addons/PaletteTools/scripts/custom_property.gd")
var custom_palette_picker = load("res://addons/PaletteTools/Scenes/custom_picker.tscn") #.instantiate()
var my_picker
var my_plugin

func _init(plugin):
	my_plugin = plugin
	my_picker = custom_palette_picker.instantiate()
	my_plugin.dock.add_child(my_picker)
	

func _can_handle(object):
	# We support all objects in this example.
	return true

func _parse_property(object, type, name, hint_type, hint_string, usage_flags, wide):
	if type == TYPE_COLOR:
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
