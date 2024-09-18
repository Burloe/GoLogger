@tool
extends EditorPlugin


func _enter_tree() -> void:
	add_autoload_singleton("GoLogger", "res://addons/GoLogger/GoLogger.tscn")
	### Disable this print specifically to remove the message alone ###
	if !GoLogger.disable_welcome_message:
		print("GoLogger version ", get_plugin_version(), " loaded. Ensure 'GoLogger.tscn' was added as an autoload properly.")
	GoLogger.project_name = ProjectSettings.get_setting("application/config/name")
	GoLogger.project_version = ProjectSettings.get_setting("application/config/version")


func _exit_tree() -> void:
	remove_autoload_singleton("GoLogger")
	InputMap.erase_action("gologger_controller_toggle")
