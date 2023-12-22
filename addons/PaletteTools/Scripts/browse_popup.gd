@tool
extends Window

const ColorPalette := preload("res://addons/PaletteTools/Scripts/palette_tool.gd")
const Alert := preload("res://addons/PaletteTools/Scripts/alert_popup_panel.gd")
const BrowsePreview := preload("res://addons/PaletteTools/Scripts/browse_palette_preview.gd")

@export var colors: ColorPalette
@export var browse_http: HTTPRequest
@export var browse_preview_scene: PackedScene
@export var preview_container: Control
@export var alert_popup: Alert
@export var loading_screen: Control

var current_page: int = 0
var close_delay: int = 4


func get_palette_list() -> void:
	browse_http.request(
        "https://lospec.com/palette-list/load?colorNumberFilterType=any&colorNumber=8&page="
        + str(current_page)
        + "&tag=&sortingType=downloads"
	)
	current_page += 1


func display_preview(palette_obj: Dictionary) -> void:
	var prev: BrowsePreview = browse_preview_scene.instantiate()
	prev.colors = colors
	prev.palette_obj = palette_obj
	prev.info_label.text = palette_obj.name + " by: " + palette_obj.author
	preview_container.add_child(prev)
	for col in palette_obj.colors:
		var new_color := ColorRect.new()
		new_color.custom_minimum_size = Vector2(75, 75)
		new_color.color = Color.from_string(col, Color.WHITE)
		prev.color_container.add_child(new_color)


func _on_close_button_pressed() -> void:
	visible = false


func _on_http_request_completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray) -> void:
	var html_text := body.get_string_from_utf8()
	var json := JSON.new()
	var err := json.parse(html_text)
	if err != OK:
		alert_popup.alert("Error getting palettes")
		return

	loading_screen.visible = false
	for pal in json.data.palettes:
		var user := "Lospec"
		var slug := ""
		if pal.has("user"):
			user = pal.user.name
		if pal.has("slug"):
			slug = pal.slug
		var palette_obj := {
			"name": pal.title,
			"author": user,
			"colors": pal.colors,
			"slug": slug
		}

		display_preview(palette_obj)


func _on_load_more_pressed() -> void:
	get_palette_list()


func _on_visibility_changed() -> void:
	if visible and current_page == 0:
		get_palette_list()


func _on_close_requested() -> void:
	hide()


func _on_focus_exited() -> void:
	while close_delay > 0:
		close_delay -= 1
		await get_tree().create_timer(1).timeout
	if not has_focus():
		hide()
		close_delay = 3


func _on_size_changed() -> void:
	close_delay = 3
