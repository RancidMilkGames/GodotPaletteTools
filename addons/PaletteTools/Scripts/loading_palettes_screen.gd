@tool
extends ColorRect

@export var loading_text: Label


func _ready() -> void:
	visible = true


func _on_visibility_changed() -> void:
	while visible:
		await get_tree().create_timer(.7).timeout
		if loading_text.text.ends_with("..."):
			loading_text.text.replace("...", "")
		else:
			loading_text.text += "."
