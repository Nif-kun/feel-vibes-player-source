extends Button
class_name StrictFocusButton

export var strict_focus := true
var _previous_focus : Control # Any control type, such as buttons.


# Called when the node enters the scene tree for the first time.
func _ready():
	# warning-ignore:RETURN_VALUE_DISCARDED
	connect("mouse_entered", self, "_on_StrictFocus_mouse_entered")
	# warning-ignore:RETURN_VALUE_DISCARDED
	connect("mouse_exited", self, "on_StrictFocus_mouse_exited")
	# warning-ignore:RETURN_VALUE_DISCARDED
	connect("pressed", self, "on_StrictFocus_pressed")


func _on_StrictFocus_mouse_entered():
	if strict_focus: # Grabs focus if not self and references the previous owner.
		if get_focus_owner() != null and get_focus_owner() != self:
			_previous_focus = get_focus_owner()
			grab_focus()


func on_StrictFocus_mouse_exited():
	if strict_focus: # Returns the focus to previous owner.
		if _previous_focus != null:
			_previous_focus.grab_focus()
			_previous_focus = null


func on_StrictFocus_pressed():
	_previous_focus = null # If directly clicked, removes the previous owner.

