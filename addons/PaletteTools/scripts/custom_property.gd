extends EditorProperty


# The main control for editing the property.
var property_control = preload("res://addons/PaletteTools/Scenes/custom_palette.tscn").instantiate()
# An internal value of the property.
# var current_value = 0
# A guard against internal changes when the property is updated.
var updating = false

var custom_palette


func _init(cust_palette, obj, named):
	custom_palette = cust_palette
#	print(get_edited_object()[get_edited_property()])


	property_control.color = obj[named]
	# Add the control as a direct child of EditorProperty node.
	add_child(property_control)
	# Make sure the control is able to retain the focus.
	add_focusable(property_control)
	# Setup the initial state and connect to the signal to track changes.
	# refresh_control_text()
	property_control.get_child(0).pressed.connect(_on_button_pressed)

#
#
func _on_button_pressed():
	custom_palette.show()
	custom_palette.get_child(0).get_node("ColorPicker").color = get_edited_object()[get_edited_property()]
	custom_palette.popup_hide.connect(cust_palette_closed, CONNECT_ONE_SHOT)
	custom_palette.get_child(0).get_node("ColorPicker").color_changed.connect(cust_palette_changed)

func cust_palette_changed(new_color):
	property_control.color = new_color
	

func cust_palette_closed():
	custom_palette.get_child(0).get_node("ColorPicker").color_changed.disconnect(cust_palette_changed)
	property_control.color = custom_palette.get_child(0).get_node("ColorPicker").color
	# Ignore the signal if the property is currently being updated.
#	if (updating):
#		return
#
#    # Generate a new random integer between 0 and 99.
#    current_value = randi() % 100
#    refresh_control_text()
	emit_changed(get_edited_property(), property_control.color)


#func _update_property():
#    # Read the current value from the property.
#    var new_value = get_edited_object()[get_edited_property()]
#    if (new_value == current_value):
#        return
#
#    # Update the control with the new value.
#    updating = true
#    current_value = new_value
#    refresh_control_text()
#    updating = false
#
#func refresh_control_text():
#    property_control.text = "Value: " + str(current_value)
