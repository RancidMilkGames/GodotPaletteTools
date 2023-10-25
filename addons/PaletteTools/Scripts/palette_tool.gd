@tool
extends Control

@onready var http: HTTPRequest = $HTTPRequest
@onready var url: LineEdit = $Palette/Search/LineEdit
@onready var color_preview = $Palette/ColorPreview
@onready var editor_swatch_save = $Palette/Container/VBoxContainer/SaveToEditor
@onready var restart_editor = $Palette/Container/VBoxContainer/RestartEditor
@onready var popup = $PopupPanel
@onready var p_name_text = $Palette/Info/PaletteName/LineEdit
@onready var p_author_text = $Palette/Info/Author/LineEdit
@onready var saved_palettes = $Palette/SavedPalettes
@onready var clear_preview_button = $Palette/HBoxContainer/Clear
@onready var col_pick_popup: PopupPanel = get_parent().get_node("Colors/ColorPickerPopup")
var add_color_scene: PackedScene = preload("res://addons/PaletteTools/Scenes/plus_box.tscn")
var color_sample = preload("res://addons/PaletteTools/Scenes/color_sample.tscn")
var my_plugin: EditorPlugin
var my_palettes = []
var config = ConfigFile.new()
var config_path = "res://addons/PaletteTools/color_presets.cfg"
var editing_color_on

signal palette_list_updated

func _ready():
	load_palettes()
	_on_new_palette_pressed()


func preview_colors(p_colors):
	for c in color_preview.get_children():
		c.queue_free()
	
	for pc in p_colors:
		var cs = color_sample.instantiate()
		cs.get_child(0).color = Color.from_string(pc, Color.RED)
		cs.get_child(0).get_picker().presets_visible = false
		cs.get_child(0).get_picker().picker_shape = ColorPicker.SHAPE_OKHSL_CIRCLE
		cs.get_child(0).get_child(0).pressed.connect(remove_color.bind(cs))
		color_preview.add_child(cs)
		
	var add_box = add_color_scene.instantiate()
	color_preview.add_child(add_box)
	add_box.get_child(0).pressed.connect(add_color_to_palette)
	
	await get_tree().create_timer(.01).timeout
	
	if color_preview.get_child_count() > 2:
		editor_swatch_save.visible = true
		clear_preview_button.visible = true
	else:
		editor_swatch_save.visible = false
		clear_preview_button.visible = false


func _on_line_edit_text_submitted(new_text):
	if new_text.length() > 0:
		http.get_palette(new_text)
	else:
		popup.get_child(0).get_child(0).text = "Please enter a URL"
		popup.show()


func load_palettes():
	my_palettes.clear()
	config.load(config_path)
	var json = JSON.new()
	if config.has_section("color_picker"):
		for sec in config.get_section_keys("color_picker"):
			my_palettes.append(json.parse_string(config.get_value("color_picker", sec)))
		
		if my_palettes.size() > 0:
			saved_palettes.clear()
			for p in my_palettes:
				saved_palettes.add_item(p.Name)
	else:
		saved_palettes.clear()
		saved_palettes.add_item("No Palettes")


func save_new_palette():
	if color_preview.get_child_count() < 2:
		popup.get_child(0).get_child(0).text = "Please add at least one color to save a palette"
		popup.show()
		return
	if p_name_text.text.length() <= 0:
		popup.get_child(0).get_child(0).text = "Please add a name to save a palette"
		popup.show()
	
	var temp_pca = []# as PackedColorArray
	for c in color_preview.get_children():
		if c == color_preview.get_child(-1):
			continue
		var color = c.get_node("Color").color
		temp_pca.append(color.to_html())

	var json = JSON.new()
	var new_pal = json.stringify({
		"Name": p_name_text.text,
		"Author": p_author_text.text,
		"Colors": temp_pca
		})
	config.set_value("color_picker", p_name_text.text, new_pal)
	config.save(config_path)
	
	load_palettes()
	palette_list_updated.emit()


func _on_save_to_editor_button_pressed():
	restart_editor.visible = true
	var settings = my_plugin.get_editor_interface().get_editor_settings()
	var temp_pca = []
	for c in color_preview.get_children():
		if c == color_preview.get_child(-1):
			continue
		var color = c.get_node("Color").color
		temp_pca.append(color.to_html())
		
	settings.set_project_metadata("color_picker", "presets", temp_pca)



func _on_restart_editor_pressed():
	my_plugin.get_editor_interface().restart_editor()


func _on_search_pressed():
	if url.text.length() > 0:
		http.get_palette(url.text)
	else:
		popup.get_child(0).get_child(0).text = "Please enter a URL"
		popup.show()


func _on_save_palette_pressed():
	save_new_palette()


func _on_popup_close_button_pressed():
	popup.hide()


func _on_load_palette_pressed():
	if saved_palettes.get_selected_items().size() <= 0:
		popup.get_child(0).get_child(0).text = "Please select a palette"
		popup.show()
		return

	if not config.has_section("color_picker"):
		popup.get_child(0).get_child(0).text = "No palettes saved"
		popup.show()
		return
	var load_color = JSON.new().parse_string(config.get_value("color_picker", saved_palettes.get_item_text(saved_palettes.get_selected_items()[0])))
	p_name_text.text = load_color.Name
	p_author_text.text = load_color.Author
	preview_colors(load_color.Colors)

func add_color_to_palette():
	var cs = color_sample.instantiate()
	editor_swatch_save.visible = true
	clear_preview_button.visible = true
	color_preview.add_child(cs)
	color_preview.move_child(cs, -2)
	editing_color_on = cs.get_child(0)
	cs.get_child(0).get_picker().presets_visible = false
	cs.get_child(0).get_picker().picker_shape = ColorPicker.SHAPE_OKHSL_CIRCLE
	cs.get_child(0).get_child(0).pressed.connect(remove_color.bind(cs))
	col_pick_popup.show()


func remove_color(obj):
	obj.queue_free()
	if color_preview.get_child_count() < 3:
		editor_swatch_save.visible = false
		clear_preview_button.visible = false


func _on_delete_palette_pressed():
	if config.has_section("color_picker"):
		config.erase_section_key("color_picker", saved_palettes.get_item_text(saved_palettes.get_selected_items()[0]))
		config.save(config_path)
	load_palettes()
	palette_list_updated.emit()


func _on_new_palette_pressed():
	p_name_text.text = ""
	p_author_text.text = ""
	saved_palettes.deselect_all()
	preview_colors([])


func _on_color_picker_color_changed(color):
	editing_color_on.color = color



func _on_saved_palettes_item_activated(index):
	_on_load_palette_pressed()


func _on_clear_pressed():
	p_name_text.text = ""
	p_author_text.text = ""
	preview_colors([])

