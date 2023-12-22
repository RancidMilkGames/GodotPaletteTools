extends EditorProperty

signal mouse_released

const CustomPalette := preload("res://addons/PaletteTools/Scripts/custom_picker.gd")

var property_control: Control
var updating := false
var custom_palette: CustomPalette


func _init(cust_palette: CustomPalette, obj: Object, named = null) -> void:
	property_control = load("res://addons/PaletteTools/Scenes/custom_palette.tscn").instantiate()
	custom_palette = cust_palette
	if named and obj[named]:
		property_control.color = obj[named]
	else:
		property_control.color = Color.BLACK
	add_child(property_control)
	add_focusable(property_control)
	property_control.get_child(0).pressed.connect(_on_button_pressed)
	resource_selected.connect(resource_prop)


func resource_prop(path: String, prop: Resource) -> void:
	if prop.get(path):
		var p := prop.get(path)
		if p is Vector4:
			property_control.color = Color(p.x, p.y, p.z, p.w)
		else:
			property_control.color = p
	else:
		property_control.color = Color.WHITE


func _on_button_pressed() -> void:
	if not custom_palette:
		push_warning(
            'Error in Palette Tools addon: If the "Palette Tools" addon was just activated, '
            + "please select a different node before trying to edit color properties of this one. "
            + "This error happens becuase the inspector was loaded before the addon. If you didn't "
            + "just activate the addon or start the Godot editor, you can try turning the addon "
            + "on and off. If the problem persists, you may need to disable the addon. If this happens, "
            + "please report any relevant info so a fix can be made. Thanks!"
		)
		return
	custom_palette.popup(Rect2(get_global_mouse_position() - Vector2(size.x, (size.y * 20)), size))
	custom_palette.color_picker.color = get_edited_object()[get_edited_property()]
	custom_palette.popup_hide.connect(cust_palette_closed, CONNECT_ONE_SHOT)
	custom_palette.color_picker.color_changed.connect(cust_palette_changed)


func cust_palette_changed(new_color: Color) -> void:
	property_control.color = new_color


func cust_palette_closed() -> void:
	custom_palette.color_picker.color_changed.disconnect(cust_palette_changed)
	property_control.color = custom_palette.color_picker.color
	emit_changed(get_edited_property(), property_control.color)


func _update_property() -> void:
	if get_edited_object() and get_edited_object()[get_edited_property()]:
		property_control.color = get_edited_object()[get_edited_property()]
	else:
		property_control.color = Color.BLACK
