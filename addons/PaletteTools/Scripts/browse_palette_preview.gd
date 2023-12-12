@tool
extends Control

const ColorPalette := preload("res://addons/PaletteTools/Scripts/palette_tool.gd")

@export var info_label: Label
@export var color_container: Control

var colors: ColorPalette
var palette_obj: Dictionary


func _on_palette_select_pressed() -> void:
	colors.import_palette_from_browse(palette_obj)
