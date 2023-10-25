@tool
extends HTTPRequest


@onready var colors_root = get_parent()
var searching = false


func get_palette(url):
	if searching:
		return
	searching = true
	if url.ends_with("/"):
		url = url.left(-1)
	var error = request(url + ".json")
	if error != OK:
		push_error("An error occurred in the HTTP request.")


func _on_request_completed(result, response_code, headers, body):
	searching = false
	var json = FileAccess.get_file_as_string(download_file)
	var json_obj = JSON.parse_string(json)
	var par = get_parent()
	par.preview_colors(json_obj.colors)
	par.p_name_text.text = json_obj.name
	par.p_author_text.text = json_obj.author
	
