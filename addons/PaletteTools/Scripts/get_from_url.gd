@tool
extends HTTPRequest

const ColorPalette := preload("res://addons/PaletteTools/Scripts/palette_tool.gd")

@export var colors: ColorPalette

var searching := false


func get_palette(url: String) -> void:
	if searching:
		return
	searching = true
	if url.ends_with("/"):
		url = url.left(-1)
	var error := request(url + ".json")
	if error != OK:
		push_error("An error occurred in the HTTP request.")


func _on_request_completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray) -> void:
	searching = false
	var json := FileAccess.get_file_as_string(download_file)
	var json_obj := JSON.parse_string(json)

	colors.preview_colors(json_obj.colors)
	colors.p_name_text.text = json_obj.name
	colors.p_author_text.text = json_obj.author
