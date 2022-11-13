extends SpinBox
class_name StrictSpinBox


# Private var:
var _regex = RegEx.new()
var _string_buffer := ""
var _is_empty := false


# Called when the script is initialized.
func _init():
	_regex.compile("^[0-9.]*$")
	# warning-ignore:RETURN_VALUE_DISCARDED
	get_line_edit().connect("text_changed", self, "_on_text_changed")
	# warning-ignore:RETURN_VALUE_DISCARDED
	get_line_edit().connect("focus_entered", self, "_on_focus_entered")
	# warning-ignore:RETURN_VALUE_DISCARDED
	get_line_edit().connect("focus_exited", self, "_on_focus_exited")
	# warning-ignore:RETURN_VALUE_DISCARDED
	connect("value_changed", self, "_on_value_changed")


# Upon focus entered: apply existing value to _string_buffer and remove the suffix.
func _on_focus_entered():
	_string_buffer = str(value)
	if !suffix.empty():
		get_line_edit().text = get_line_edit().text.replace(suffix, "").replace(" ", "")


# Upon focus exited: ensure that spinbox is not empty and remove existing period on string end.
func _on_focus_exited():
	if get_line_edit().text.empty():
		get_line_edit().text = _string_buffer
	else:
		if get_line_edit().text.ends_with("."):
			get_line_edit().text = get_line_edit().text.replace(".", "")


# Upon text changed: ensures that only numerical values are accepted.
func _on_text_changed(text : String):
	if !text.empty():
		if _regex.search(text) and text.is_valid_float():
			_string_buffer = text
			_is_empty = false
		elif !_is_empty:
			if text == ".":
				get_line_edit().text = "0."
			else:
				get_line_edit().text = _string_buffer
			get_line_edit().set_cursor_position(get_line_edit().text.length())
		else:
			if text == ".":
				_string_buffer = "0."
				get_line_edit().text = _string_buffer
				get_line_edit().set_cursor_position(get_line_edit().text.length())
				_is_empty = false
			else:
				get_line_edit().text = ""
	else:
		_is_empty = true


# Updates _string_buffer when value is changed directly from the side button of the spinbox.
func _on_value_changed(value):
	_string_buffer = str(value)


func set_script_all():
	pass
