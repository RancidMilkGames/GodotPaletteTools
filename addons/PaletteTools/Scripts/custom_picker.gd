@tool
extends PopupPanel

@export var color_picker: ColorPicker
@export var saved_palettes: ItemList
@export var apply_palette_button: Button


func _init() -> void:
	hide()
	min_size = Vector2i(320, 675)
	size = Vector2i(320, 675)
	if DisplayServer.screen_get_size().x > 2000:
		min_size *= 2
		size *= 2
