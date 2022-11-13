extends StrictFocusButton
class_name IconButton

#Note: priority is hover enter is > than focus enter and focus exit is > than hover exit

# Public var
export var sub_icon : Texture
export var replace_on_toggle := false
export var replace_on_hover := false
export var replace_on_focus := false

# Private var
var _default_icon : Texture


# Called when the node enters the scene tree for the first time.
func _ready():
	_default_icon = icon
	# warning-ignore:RETURN_VALUE_DISCARDED
	connect("toggled", self, "_on_toggled")
	# warning-ignore:RETURN_VALUE_DISCARDED
	connect("mouse_entered", self, "_on_mouse_entered")
	# warning-ignore:RETURN_VALUE_DISCARDED
	connect("mouse_exited", self, "on_mouse_exited")
	# warning-ignore:RETURN_VALUE_DISCARDED
	connect("focus_entered", self, "_on_focus_entered")
	# warning-ignore:RETURN_VALUE_DISCARDED
	connect("focus_exited", self, "_on_focus_exited")


func _on_toggled(flag:bool):
	if replace_on_toggle and sub_icon != null:
		if flag and icon != sub_icon:
			icon = sub_icon
		if not flag and icon == sub_icon:
			icon = _default_icon


func _on_mouse_entered():
	if replace_on_hover and sub_icon != null:
		if icon != sub_icon:
			icon = sub_icon


func on_mouse_exited():
	if replace_on_hover and sub_icon != null:
		if !replace_on_focus or (get_focus_owner() != null and get_focus_owner() != self):
			if icon == sub_icon:
				icon = _default_icon


func _on_focus_entered():
	if replace_on_focus and sub_icon != null:
		if icon != sub_icon:
			icon = sub_icon


func _on_focus_exited():
	if replace_on_focus and sub_icon != null:
		if icon == sub_icon:
			icon = _default_icon
