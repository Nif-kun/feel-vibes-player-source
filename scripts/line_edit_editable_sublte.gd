extends LineEdit
class_name SubtleLineEdit

export var prefix := ""
export var suffix := ""


# Called when the node enters the scene tree for the first time.
func _ready():
	# warning-ignore:RETURN_VALUE_DISCARDED
	connect("focus_exited", self, "_on_focus_exited")


func _gui_input(event):
	# Removes prefix and suffix before allowing edit.
	if event.is_action_pressed("mouse_left") and event.doubleclick:
		text = text.trim_prefix(prefix+" ")
		text = text.trim_suffix(" "+suffix)
		editable = true
		# Fixes missing caret.
		var _caret_blink = caret_blink
		caret_blink = true
		if not _caret_blink:
			caret_blink = false


func _on_focus_exited():
	# Removes whitespaces and adds a suffix or a prefix if not empty.
	if editable:
		if !text.empty():
			text = text.strip_edges()
			text = text.strip_escapes()
			while true:
				if text.find("  ") > -1:
					text = text.replace("  ", " ")
				else:
					break
			if !prefix.empty():
				text = prefix +" "+ text
			if !suffix.empty():
				text = text +" "+ suffix
		editable = false
