class_name GLShortcut extends Resource

@export var start_session_hotkey: InputEvent # Only use InputEventShortcut if you want to bind multiple hotkeys
@export var stop_session_hotkey: InputEvent
@export var display_instance_id_hotkey: InputEvent
@export_multiline("Use InputEventShortcut to use as many bindings as you want. \nNote that only [InputEventShortcut] [InputEventMouseButton] and [InputEvenJoybadButtons] are supported!") var info: String = "Use InputEventShortcut to use as many bindings as you want. \nNote that only [InputEventShortcut] [InputEventMouseButton] and [InputEvenJoybadButtons] are supported!":
	set(value):
		info = info
@export var asdf: InputEvent

func get_hotkeys() -> Array[InputEvent]:
	return [start_session_hotkey, stop_session_hotkey, display_instance_id_hotkey]