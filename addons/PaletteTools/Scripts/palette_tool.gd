@tool
extends Control

const Alert := preload("res://addons/PaletteTools/Scripts/alert_popup_panel.gd")
const URLHTTP := preload("res://addons/PaletteTools/Scripts/get_from_url.gd")
const BrowsePalettes := preload("res://addons/PaletteTools/Scripts/browse_popup.gd")
const PalettePlugin := preload("res://addons/PaletteTools/palette_tools.gd")
const ColorSample := preload("res://addons/PaletteTools/Scripts/color_sample.gd")

signal palette_list_updated

@export var http: URLHTTP
@export var url: LineEdit
@export var color_preview: HFlowContainer
@export var editor_swatch_save: Control
@export var restart_editor: Control
@export var alert: Alert
@export var p_name_text: LineEdit
@export var p_author_text: LineEdit
@export var saved_palettes: ItemList
@export var clear_preview_button: Button
@export var col_pick_popup: PopupPanel
@export var browse_popup_panel: BrowsePalettes
@export var add_color_scene: PackedScene
@export var color_sample: PackedScene
@export var custom_picker_check_box: CheckBox
var my_plugin: PalettePlugin
var my_palettes: Array[Dictionary] = []
var config := ConfigFile.new()
var config_path := "res://addons/PaletteTools/color_presets.cfg"
var editing_color_on: ColorPickerButton
var four_k_plus: bool = false


func _ready() -> void:
	if DisplayServer.screen_get_size().x > 2000:
		four_k_plus = true
	load_palettes()
	_on_new_palette_pressed()
	iterate_for_control_sizing(self)


## We want to size the plugin to look good in both 1080p and 4k
func iterate_for_control_sizing(node: Node) -> void:
	##TODO: See if there's anything to do about this if/else abomination
	if node is Window:
		return

	if node is Label and node.label_settings:
		if "Title" in node.name:
			if node.name == "Title":
				if four_k_plus:
					node.label_settings.font_size = 80
				else:
					node.label_settings.font_size = 40
			else:
				if four_k_plus:
					node.label_settings.font_size = 50
				else:
					node.label_settings.font_size = 25
		else:
			if four_k_plus:
				node.label_settings.font_size = 40
			else:
				node.label_settings.font_size = 22

	if node is CheckBox:
		if four_k_plus:
			node.add_theme_icon_override("checked", load("res://addons/PaletteTools/Images/checked_4k.png"))
			node.add_theme_icon_override("unchecked", load("res://addons/PaletteTools/Images/unchecked_4k.png"))
		else:
			node.add_theme_icon_override("checked", load("res://addons/PaletteTools/Images/checked.png"))
			node.add_theme_icon_override("unchecked", load("res://addons/PaletteTools/Images/unchecked.png"))
	
	if node is RichTextLabel:
		if four_k_plus:
			node.add_theme_font_size_override("normal_font_size", 40)
		else:
			node.add_theme_font_size_override("normal_font_size", 20)

	if node is Button or node is TextureButton or node is LineEdit or node is ItemList:
		if (node is Button and node.icon) or node is TextureButton:
			if four_k_plus:
				node.custom_minimum_size = Vector2i(80, node.get_minimum_size().y)
			else:
				node.custom_minimum_size = Vector2i(40, node.get_minimum_size().y)
			node.update_minimum_size()
		else:
			if four_k_plus:
				node.add_theme_font_size_override("font_size", 30)
			else:
				node.add_theme_font_size_override("font_size", 16)
	for c in node.get_children():
		iterate_for_control_sizing(c)


func size_color_sample(cs: ColorSample) -> void:
	if four_k_plus:
		cs.custom_minimum_size = Vector2i(95, 95)
		cs.remove_button.custom_minimum_size = Vector2i(30, 30)
		cs.remove_button_text.label_settings.font_size = 20
	else:
		cs.custom_minimum_size = Vector2i(40, 40)
		cs.remove_button.custom_minimum_size = Vector2i(10, 10)
		cs.remove_button_text.label_settings.font_size = 10
	cs.update_minimum_size()
	cs.remove_button.update_minimum_size()


func preview_colors(p_colors: PackedStringArray) -> void:
	for c in color_preview.get_children():
		c.queue_free()

	for pc: String in p_colors:
		var cs: ColorSample = color_sample.instantiate()
		var col_pick_btn := cs.color_picker_button as ColorPickerButton
		col_pick_btn.color = Color.from_string(pc, Color.RED)
		col_pick_btn.get_picker().presets_visible = false
		col_pick_btn.get_picker().picker_shape = ColorPicker.SHAPE_OKHSL_CIRCLE

		if four_k_plus:
			cs.remove_button.size = Vector2i(20, 20)
		else:
			cs.remove_button.size = Vector2i(10, 10)

		cs.remove_button.pressed.connect(remove_color.bind(cs))
		color_preview.add_child(cs)
		size_color_sample(cs)

	var add_box := add_color_scene.instantiate()
	if four_k_plus:
		add_box.custom_minimum_size = Vector2i(95, 95)
	else:
		add_box.custom_minimum_size = Vector2i(40, 40)
	color_preview.add_child(add_box)
	add_box.update_minimum_size()
	add_box.get_child(0).pressed.connect(add_color_to_palette)

	await get_tree().create_timer(.01).timeout

	if color_preview.get_child_count() > 2:
		editor_swatch_save.visible = true
		clear_preview_button.visible = true
	else:
		editor_swatch_save.visible = false
		clear_preview_button.visible = false


func _on_line_edit_text_submitted(new_text: String) -> void:
	if new_text.length() > 0:
		http.get_palette(new_text)
	else:
		alert.alert("Please enter a URL")


func load_palettes() -> void:
	my_palettes.clear()
	config.load(config_path)
	var json := JSON.new()
	if config.has_section("color_picker"):
		for sec in config.get_section_keys("color_picker"):
			my_palettes.append(json.parse_string(config.get_value("color_picker", sec)))

		if my_palettes.size() > 0:
			saved_palettes.clear()
			for p in my_palettes:
				saved_palettes.add_item(p.name)
	else:
		saved_palettes.clear()
		saved_palettes.add_item("No Palettes")


func save_new_palette() -> void:
	if color_preview.get_child_count() < 2:
		alert.alert("Please add at least one color to save a palette")
		return
	if p_name_text.text.length() <= 0:
		alert.alert("Please add a name to save a palette")
		return

	var temp_pca: Array[String] = []
	for c in color_preview.get_children():
		if c == color_preview.get_child(-1):
			continue
		var color = (c as ColorSample).color_picker_button.color
		temp_pca.append(color.to_html())

	var json := JSON.new()
	var new_pal := json.stringify({
		"name": p_name_text.text,
		"author": p_author_text.text,
		"colors": temp_pca
		})
	config.set_value("color_picker", p_name_text.text, new_pal)
	config.save(config_path)

	load_palettes()
	palette_list_updated.emit()


func _on_save_to_editor_button_pressed() -> void:
	restart_editor.visible = true
	var settings = my_plugin.get_editor_interface().get_editor_settings()
	var temp_pca: Array[String] = []
	for c in color_preview.get_children():
		if c == color_preview.get_child(-1):
			continue
		var color := c.get_node("Color").color as Color
		temp_pca.append(color.to_html())

	settings.set_project_metadata("color_picker", "presets", temp_pca)


func _on_restart_editor_pressed() -> void:
	my_plugin.get_editor_interface().restart_editor()


func _on_search_pressed() -> void:
	if url.text.length() > 0:
		http.get_palette(url.text)
	else:
		alert.alert("Please enter a URL")


func _on_save_palette_pressed() -> void:
	save_new_palette()


func _on_load_palette_pressed() -> void:
	if saved_palettes.get_selected_items().size() <= 0:
		await get_tree().process_frame
		alert.alert("Please select a palette")
		return

	if not config.has_section("color_picker"):
		alert.alert("No palettes saved")
		return
	var load_color := JSON.parse_string(config.get_value("color_picker", saved_palettes.get_item_text(saved_palettes.get_selected_items()[0])))
	p_name_text.text = load_color.name
	p_author_text.text = load_color.author
	preview_colors(load_color.colors)


func add_color_to_palette() -> void:
	var cs: ColorSample = color_sample.instantiate() as ColorSample
	editor_swatch_save.visible = true
	clear_preview_button.visible = true
	color_preview.add_child(cs)
	color_preview.move_child(cs, -2)
	size_color_sample(cs)
	editing_color_on = cs.color_picker_button as ColorPickerButton
	editing_color_on.get_picker().presets_visible = false
	editing_color_on.get_picker().picker_shape = ColorPicker.SHAPE_OKHSL_CIRCLE
	cs.remove_button.pressed.connect(remove_color.bind(cs))
	cs.color_picker_button.get_popup().popup(
		Rect2(
			get_global_mouse_position() - Vector2(size.x, size.y * 20),
			cs.color_picker_button.get_popup().size
		)
	)


func remove_color(obj: Node) -> void:
	obj.queue_free()
	if color_preview.get_child_count() < 3:
		editor_swatch_save.visible = false
		clear_preview_button.visible = false


func _on_delete_palette_pressed() -> void:
	if config.has_section("color_picker"):
		config.erase_section_key("color_picker", saved_palettes.get_item_text(saved_palettes.get_selected_items()[0]))
		config.save(config_path)
	load_palettes()
	palette_list_updated.emit()


func _on_new_palette_pressed() -> void:
	p_name_text.text = ""
	p_author_text.text = ""
	saved_palettes.deselect_all()
	preview_colors([])


func _on_color_picker_color_changed(color: Color) -> void:
	editing_color_on.color = color


func _on_saved_palettes_item_activated(_index: int) -> void:
	_on_load_palette_pressed()


func _on_clear_pressed() -> void:
	p_name_text.text = ""
	p_author_text.text = ""
	preview_colors([])


func import_palette_from_browse(palette_obj: Dictionary) -> void:
	p_name_text.text = palette_obj.name
	p_author_text.text = palette_obj.author
	preview_colors(palette_obj.colors)


func _on_browse_palettes_button_pressed() -> void:
	browse_popup_panel.visible = true


func _on_custom_picker_check_box_toggled(toggled_on: bool) -> void:
	my_plugin.toggle_custom_picker(toggled_on)
