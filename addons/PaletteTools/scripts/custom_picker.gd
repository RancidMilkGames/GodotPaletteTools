@tool
extends PopupPanel

@onready var color_picker: ColorPicker = $ScrollContainer/VBoxContainer/ColorPicker
@onready var saved_palettes: ItemList = $ScrollContainer/VBoxContainer/SavedPalettes

func _init():
	hide()
