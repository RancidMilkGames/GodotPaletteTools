extends EditorProperty

signal mouse_released

var property_control = preload("res://addons/PaletteTools/Scenes/custom_palette.tscn").instantiate()
var updating = false
var custom_palette


func _init(cust_palette, obj, named = null):
	custom_palette = cust_palette
	if named and obj[named]:
		property_control.color = obj[named]
	else:
		property_control.color = Color.BLACK
	add_child(property_control)
	add_focusable(property_control)
	property_control.get_child(0).pressed.connect(_on_button_pressed)
	resource_selected.connect(resource_prop)


func resource_prop(path, prop):
	if prop.get(path):
		var p = prop.get(path)
		if p is Vector4:
			property_control.color = Color(p.x, p.y, p.z, p.w)
		else:
			property_control.color = p
	else:
		property_control.color = Color.WHITE


func _on_button_pressed():
	if not custom_palette:
		push_warning("Error in Palette Tools addon: If the \"Palette Tools\" addon was just activated, " +
		"please select a different node before trying to edit color properties of this one. " +
		"This error happens becuase the inspector was loaded before the addon. If you didn't " +
		"just activate the addon or start the Godot editor, you can try turning the addon " +
		"on and off. If the problem persists, you may need to disable the addon. If this happens, " +
		"please report any relevant info so a fix can be made. Thanks!")
		return
	custom_palette.show()
	custom_palette.color_picker.color = get_edited_object()[get_edited_property()] #get_child(0).get_child(0).get_node("ColorPicker").color = get_edited_object()[get_edited_property()]
	custom_palette.popup_hide.connect(cust_palette_closed, CONNECT_ONE_SHOT)
	custom_palette.color_picker.color_changed.connect(cust_palette_changed) #get_child(0).get_child(0).get_node("ColorPicker").color_changed.connect(cust_palette_changed)


func cust_palette_changed(new_color):
	property_control.color = new_color


func cust_palette_closed():
	custom_palette.get_child(0).get_child(0).get_node("ColorPicker").color_changed.disconnect(cust_palette_changed)
	property_control.color = custom_palette.get_child(0).get_child(0).get_node("ColorPicker").color
	emit_changed(get_edited_property(), property_control.color)


func _update_property():
	if get_edited_object() and get_edited_object()[get_edited_property()]:
		property_control.color = get_edited_object()[get_edited_property()]
	else:
		property_control.color = Color.BLACK
