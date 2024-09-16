@tool
extends EditorPlugin


func _enter_tree() -> void:
	add_autoload_singleton("GoLogger", "res://addons/GoLogger/GoLogger.tscn")
	
	#region COMMENT OUT / REMOVE CONTENT IN THIS CODE REGION TO STOP WELCOME MESSAGE 
	if !InputMap.has_action("gologger_controller_toggle"):
		InputMap.add_action("gologger_controller_toggle")
		var tempkey = InputEventKey.new()
		tempkey.keycode = KEY_F9
		InputMap.action_add_event("gologger_controller_toggle", tempkey)
	### Disable this print specifically to remove the message alone ###
	if !GoLogger.disable_welcome_message:
		print("GoLogger version ", get_plugin_version(), " loaded. Ensure 'GoLogger.tscn' was added as an autoload properly.")
	#endregion


func _exit_tree() -> void:
	remove_autoload_singleton("GoLogger")
	InputMap.erase_action("gologger_controller_toggle")
