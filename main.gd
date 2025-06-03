extends Control

@export var editor: CodeEdit
@export var error_label: Label

func _on_code_edit_text_changed() -> void:
	var err: LuaError = $Node2D.lua.do_string(editor.text)
	if err is LuaError:
		error_label.text = "ERROR %d: %s" % [err.type, err.message]
	else:
		error_label.text = "Okay"
	$Node2D.reset_audio()


func _on_mute_button_pressed() -> void:
	$Node2D.muted = not $Node2D.muted


func _on_play_pause_button_pressed() -> void:
	pass # Replace with function body.


func _on_back_button_pressed() -> void:
	pass # Replace with function body.


func _on_volume_slider_value_changed(value: float) -> void:
	$Node2D.volume = value / 100.0
