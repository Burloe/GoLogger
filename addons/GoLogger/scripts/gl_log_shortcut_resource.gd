class_name GLShortcut extends Resource

@export var start_session_hotkey: InputEventShortcut ## Default: Ctrl + Shift + O 
@export var stop_session_hotkey: InputEventShortcut ## Default: Ctrl + Shift + P
@export var display_instance_id_hotkey: InputEventShortcut # Default: Ctrl + Shift + I

## Returns an array of the [InputEventShortcut] hotkeys in order: [br]
## [ start_session, stop_session, instance_id ]
func get_hotkeys() -> Array[InputEvent]:
	return [start_session_hotkey, stop_session_hotkey, display_instance_id_hotkey]