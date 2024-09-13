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
	print("GoLogger loaded. Thanks for downloading! Before using GoLogger, ensure 'GoLogger.tscn' was added properly as an autoload. Additionally, a new InputMap Action was added(KEY_F9) used to toggle the controller module in your game. Message can be disabled in 'res://addons/GoLogger/plugin.gd")
	#endregion


func _exit_tree() -> void:
	remove_autoload_singleton("GoLogger")
	InputMap.erase_action("gologger_controller_toggle")
