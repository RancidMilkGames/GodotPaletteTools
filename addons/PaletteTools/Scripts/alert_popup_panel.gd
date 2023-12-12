@tool
extends PopupPanel

@export var alert_text_label: Label


func alert(message: String) -> void:
	alert_text_label.text = message
	show()


func _on_close_button_pressed() -> void:
	hide()


func _on_close_requested() -> void:
	hide()
