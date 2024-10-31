extends Node

#region Documentation & Declarations
## Autoload containing the entire framework that is GoLogger. 
##
## The GitHub repository [url]https://github.com/Burloe/GoLogger[/url] will always have the latest version of GoLogger to download. For installation, setup and 
## how to use instructions, see the README.md or in the Github repo.[br][br] This framework will create folders for each log category in the directory specified 
## in [param base_directory] in which .log files are created. You can add however many log categories you want by adding more [LogFileResource]s into the arrray 
## [param categories]. This plugin uses 'sessions' to indicate when it's logging and each session creates one .log file. To use this plugin, there are four main 
## functions when using this plugin which can be called from any script in your project:[br][br][method start_session]: Starts a session and creates a .log file. 
## When [param autostart_session] is enabled, the plugin calls this function by itself when running your project.[br][method entry]: Main bread and butter of this 
## plugin. Call this in your code to log entries into the .log file. In order to log an entry into different categories, you specify the category by the category's 
## array position in [param categories].[codeblock]
## Log.entry("My first game log entry", 0) # Logs entry into category 0 named 'game'.
## Log.entry("My first game log entry") # Alternative. Not specifying the category will log into category 0.
## Log.entry("My first player log entry", 1) # Log entry into category 1 named 'player[/codeblock]
## [method save_copy]: Copies the active session log into a separate .log file that's saved into [code]base_directory/categoryname_Gologs/saved_logs/[/code]. 
## Files saved into the subfolder are exempt from being deleted. This plugin will delete the oldest entry when the number of logs exceeds [param file_cap] so log 
## files aren't created endlessly.[br][method stop_session]: Stops the active session and stops logging to the corresponding .log file.



## Emitted when the session status has changed.  
signal session_status_changed 

## Emitted when the [param session_timer] is started. Useful to sync up sessions with systems/features for other applications than simple file management. 
## E.g. when stress testing some system or feather or to log for a specific time.
signal session_timer_started   

## Set the base filepath where folders for each log category are created. For each [LogFileResource] within [param file], a corresponding folder is created where 
## the logs are stored.[br][color=red][b]Warning:[/b][br]Changing this parameter at runtime will likely cause errors.
@export var base_directory : String = "user://GoLogger/"

## Array containing [LogFileResource]s that each corresponds to a log category. They define the category name.
@export var categories : Array[LogFileResource] = [preload("res://addons/GoLogger/Resources/DefaultLogFile.tres")] 

## Determines the type of header used in the .log file header. Gets the project name and version from Project Settings > Application > Config.[br]
## [i]"Project X version 0.84 - Game Log session started[2024-09-16 21:38:04]:"
@export_enum("Project name & version", "Project name", "Project version", "None") var log_header : int = 0

## Autostarts the session at runtime.
@export var autostart_session 			: bool = true

## Uses UTC time as opposed to the users local system time. 
@export var use_utc : bool = false

## When enabled, date and timestamps are separated with '-'.[br]Disabled = "categoryname_241028_182143.log".[br]Enabled  = "categoryname_24-10-28_18-21-43.log".
@export var dash_timestamp_separator : bool = false

## Contains the resulting string as determined by [param log_header].
var header_string : String

@export_group("Log Management") 
## Flags which log management method used to prevent long or large .log files. [i]Added to combat potential performance issues. Using [param entry_count_limit] 
## is still recommended to use regardless if you experience performance issues or not.[/i][br]
## [b]1. Entry count Limit:[/b] Checks entry count when logging a new one. If count exceeds [param entry_count_limit], oldest entry is removed to make room for 
## the new entry.[br]
## [b]2. Session Timer:[/b] Upon session is start, [param session_timer] is also started, counting down the [param session_timer_wait_time] value. Upon 
## [signal timeout], session is stopped and the action is determined by [param limit_action].[br]
## [b]3. Entry Count Limit + Session Timer:[/b] Uses both of the above methods.[br]
## [b]4. None:[/b] Uses no methods of preventing too large files. Not recommended.
@export_enum("Entry Count Limit", "Session Timer", "Entry Limit + Session Timer", "None") var limit_method : int = 0

## The log entry count(or line count) limit allowed in the .log categories. If entry count exceeds this number, the oldest entry 
## is removed before adding the new.[br] [b]Stop & start new session:[/b] Stops the current session and starting a new one.[br]
## [b]Stop session only:[/b] Stops the current session without starting a new one.
@export_enum("Stop & start new session", "Stop session only") var limit_action : int = 0

## Sets the max number of log files. Deletes the oldest log file in directory when file count exceeds this number
@export var file_cap : int = 10

## The maximum number of log entries allowed in one file before it starts to delete the oldest entry when adding a new.
@export var entry_count_limit : int = 1000

## The current count of entries in the game.log.
var entry_count_game : int = 0 

## The current count of entries in the player.log.
var entry_count_player : int = 0 

## Timer node that tracks the session time. Will stop and start new sessions on [signal timeout].
@onready var session_timer : Timer = $SessionTimer

## Default length of time for a session when [param Session Timer] is enabled.
@export var session_timer_wait_time : float = 600.0:
	set(new):
		session_timer_wait_time = new
		if session_timer != null: session_timer.wait_time = session_timer_wait_time

@export_group("Error Reporting")
## Enables/disables all debug warnings and errors.[br]'All' - Enables errors and warnings.[br]'Only Warnings' - Disables errors and 
## only allows warnings.[br]'None' - All errors and warnings are disabled.
@export_enum("All", "Only Warnings", "None") var error_reporting : int = 0

## If true, enables printing messages to the output when a log session is started or stopped.
@export_enum("None", "Start & Stop Session", "Start Session only", "Stop Session only") var print_session_changes : int = 0 

## Disables the "Attempted to start new log session before stopping the previous" warning.
@export var disable_session_warning : bool = false

## Disables the "Attempt to log entry failed due to inactive session" warning.
@export var disable_entry_warning : bool = false

## Flags whether or not a session is active.
var session_status : bool = false:
	set(value):
		session_status = value
		session_status_changed.emit()

@export_group("Hotkeys")
## Hotkey used to start session manually. Default hotkey: [kbd]Ctrl + Shift + O[/kbd]
@export var hotkey_start_session: InputEventShortcut = preload("res://addons/GoLogger/Resources/StartSessionShortcut.tres")

## Hotkey used to stop session manually. Default hotkey: [kbd]Ctrl + Shift + P[/kbd]
@export var hotkey_stop_session	: InputEventShortcut = preload("res://addons/GoLogger/Resources/StopSessionShortcut.tres")			

## Hotkey used to save the currently active session with a unique filename. Default hotkey: [kbd]Ctrl + Shift + U[/kbd]
@export var hotkey_copy_session : InputEventShortcut = preload("res://addons/GoLogger/Resources/CopySessionShortcut.tres")		

## Shortcut binding used to toggle the controller's visibility(supports joypad bindings).
@export var hotkey_controller_toggle: InputEventShortcut = preload("res://addons/GoLogger/Resources/ToggleControllerShortcut.tres") 	

@export_group("LogController")
## Sets the [param layer] property of the [CanvasLayer] containing the Controller and Copy Popup.
@export var canvaslayer_layer : int = 5:				
	set(value):
		canvaslayer_layer = value
		$GoLoggerElements.layer = value

## Hides GoLoggerController when running your project. Use hotkey defined in [param hotkey_toggle_controller]. [kbd]Ctrl + Shift + K[/kbd] by default.
@export var hide_contoller_on_start	: bool = true

## The offset used to correct the controller window position while dragging(depending on any potential scaling or resolution).
@export var controller_drag_offset	: Vector2 = Vector2(0, 0)

# Popup
@onready var popup : CenterContainer = $GoLoggerElements/Popup
@onready var popup_textedit : TextEdit = $GoLoggerElements/Popup/Panel/MarginContainer/VBoxContainer/TextEdit
@onready var popup_yesbtn : Button = $GoLoggerElements/Popup/Panel/HBoxContainer/YesButton
@onready var popup_nobtn : Button = $GoLoggerElements/Popup/Panel/HBoxContainer/NoButton
@onready var popup_errorlbl : RichTextLabel = $GoLoggerElements/Popup/Panel/ErrorLabel

## When true, this bool activates the popup prompt that allows you to enter a file copy name. 
var popup_state : bool = false: 
	set(value):
		if session_status:
			popup_state = value
			popup.visible = value
			popup_textedit.editable = value
			popup_nobtn.disabled  = !value
			if value:
				popup_textedit.focus_mode = Control.FOCUS_ALL
				popup_yesbtn.focus_mode   = Control.FOCUS_ALL
				popup_nobtn.focus_mode    = Control.FOCUS_ALL
				popup_textedit.grab_focus()
			else:
				popup_textedit.focus_mode = Control.FOCUS_NONE
				popup_yesbtn.focus_mode   = Control.FOCUS_NONE
				popup_nobtn.focus_mode    = Control.FOCUS_NONE

## When saving  file copies of the current session, the entered name is stored in this variable.
var copy_name : String = "" 
#endregion


func _input(event: InputEvent) -> void:
	if !Engine.is_editor_hint():
		if event is InputEventKey or event is InputEventJoypadButton or event is InputEventJoypadMotion:
			if Log.hotkey_start_session.shortcut.matches_event(event) and event.is_released():
				start_session()
			if Log.hotkey_stop_session.shortcut.matches_event(event) and event.is_released():
				stop_session()
			if Log.hotkey_save_unique.shortcut.matches_event(event) and event.is_released():
				save_copy()



func _ready() -> void:
	if !Engine.is_editor_hint():
		$GoLoggerElements.layer = canvaslayer_layer
		header_string = get_header()
		session_timer.autostart = autostart_session
		popup.visible = popup_state
		popup_errorlbl.visible = false
		assert(check_filename_conflicts() == "", str("GoLogger Error: Conflicting category_name '", check_filename_conflicts(), "' found more than once in LogFileResource. Please assign a unique name to all LogFileResources in the 'categories' array."))
		if autostart_session:
			start_session()
		add_hotkeys()
	



#region Main Plugin Functions
## Initiates a log session, recording user defined game events in the .log categories.
## [br][param start_delay] can be used to prevent log files with the same timestamp from being generated, but requires function to be called using the 
## "await" keyword: [code]await Log.start_session(1.0)[/code]. See README[Starting and stopping sessions] for more info.[br]Example usage:[codeblock]
##	Log.start_session()                       # Normal call
##	await Log.start session(1.2)              # Calling with a start delay[/codeblock]
func start_session(start_delay : float = 0.0) -> void:
	if !Engine.is_editor_hint():
		if start_delay > 0.0:
			await get_tree().create_timer(start_delay).timeout
		if limit_method == 1 or limit_method == 2:
			session_timer.start(session_timer_wait_time)
			session_timer_started.emit()
		if print_session_changes == 1 or print_session_changes == 3:
			print("GoLogger: Session started!")

		# Iterate over each LogFileResource in [param categories] array > Create directories and files 
		for i in range(categories.size()):
			assert(categories[i] != null, str("GoLogger Error: 'categories' array entry", i, " has no [LogFileResource] added."))

			var _fname : String
			_fname = get_file_name(categories[i].category_name) if categories[i].category_name != "" else str("file", i)
			var _path : String = str(base_directory, categories[i].category_name, "_Gologs/")
			if _path == "": 
				if error_reporting == 0: 
					push_error(str("GoLogger Error: Failed to start session due to invalid directory path(", _fname, "). Please assign a valid directory path."))
				if error_reporting == 1:
					push_warning(str("GoLogger Error: Failed to start session due to invalid directory path(", _fname, "). Please assign a valid directory path."))
				return
			if session_status:
				if error_reporting != 2 and !disable_session_warning:
					push_warning("GoLogger Warning: Failed to start session, a session is already active.")
				return

			else:
				var _dir : DirAccess
				if !DirAccess.dir_exists_absolute(_path):
					DirAccess.make_dir_recursive_absolute(_path)
				var _dd : DirAccess # Create sub-folders for saved logs
				if !DirAccess.dir_exists_absolute(str(_path, "saved_logs/")):
					DirAccess.make_dir_recursive_absolute(str(_path, "saved_logs/"))

				_dir = DirAccess.open(_path)
				if !_dir and error_reporting != 2:
					var _err = DirAccess.get_open_error()
					if _err != OK: push_warning("GoLogger ", get_err_string(_err), " (", _path, ").")
					return
				else:
					categories[i].current_filepath = _path + get_file_name(categories[i].category_name)
					categories[i].current_file = get_file_name(categories[i].category_name)
					var _f = FileAccess.open(categories[i].current_filepath, FileAccess.WRITE)
					var _files = _dir.get_files()
					categories[i].file_count = _files.size()
					while _files.size() > file_cap -1:
						_files.sort()
						_dir.remove(_files[0])
						_files.remove_at(0)
						var _err = DirAccess.get_open_error()
						if _err != OK and error_reporting != 2: push_warning("GoLoggger Error: Failed to remove old log file -> ", get_err_string(_err))
					if !_f and error_reporting != 2: push_warning("GoLogger Error: Failed to create log file(", categories[i].current_file, ").")
					else:
						var _s := str(header_string, categories[i].category_name, " Log session started[", Time.get_datetime_string_from_system(use_utc, true), "]:")
						_f.store_line(_s)
						categories[i].entry_count = 0
						_f.close()
		if print_session_changes == 1 or print_session_changes == 2: print("GoLogger: Started session.")
		session_status = true



## Stores a log entry into the a .log file. You can add data to the log entry(as long as the data can be converted into a string) and specify which category the entry
## should be store in.[br][br]
## [param category_index] determine which log category this entry will be stored in. The category_index index corresponds to the order of [LogFileResource] entries in 
## the [param categories] array. Note that leaving this parameter undefined will store the entry in category 0.[br][br][param timestamp] enables you to include a timestamp 
## of when the entry was added to your log.[br][br]Example usage:[codeblock]
## Log.entry(str("Player healed for ", item.heal_amount, "HP by consuming", item.item_name, "."), 1)
## # Resulting log entry stored in category 1: [16:34:59] Player healed for 55HP by consuming Medkit.[/codeblock]
func entry(log_entry : String, category_index : int = 0, include_timestamp : bool = true) -> void:
	if !Engine.is_editor_hint():
		var _timestamp : String = str("[", Time.get_time_string_from_system(use_utc), "] ") 

		if !session_status:
			if error_reporting != 2 and !disable_entry_warning: push_warning("GoLogger Warning: Failed to log entry due to inactive session.")
			return
		else:
			var _f = FileAccess.open(categories[category_index].current_filepath, FileAccess.READ)
			if !_f:
				var _err = FileAccess.get_open_error()
				if _err != OK and error_reporting != 2: push_warning("Gologger Error: Log entry failed due to FileAccess error[", get_err_string(_err), "]")
			var _c = _f.get_as_text()
			var lines : Array[String] = []
			while not _f.eof_reached():
				var _l = _f.get_line().strip_edges(false, true)
				if _l != "":
					lines.append(_l)
				_f.close()

				# Remove old entries at line 1 until entry count is less than limit.
				if limit_method == 0 or limit_method == 2:
					while lines.size() > entry_count_limit:
						lines.remove_at(1)
				categories[category_index].entry_count = lines.size()

				# Open file with write and store the new entry
				var _fw = FileAccess.open(categories[category_index].current_filepath, FileAccess.WRITE)
				if !_fw and error_reporting != 2:
					var err = FileAccess.get_open_error()
					if err != OK: push_warning("GoLogger error: Log entry failed due to FileAccess error[", get_err_string(err), "]")
				var _entry : String = str("\t", _timestamp, log_entry) if include_timestamp else str("\t", log_entry)
				_fw.store_line(str(_c, _entry))
				_fw.close()



## Initiates the "save copy" operation by displaying the popup prompt. Once a name has been entered and confirmed. [method complete_copy] is called.
func save_copy() -> void:
	if !Engine.is_editor_hint(): popup_state = !popup_state



## Saves the actual copies of the current log session in "saved_logs" sub-folders. [br][b]Note:[br][/b]   This function should never be called to perform the "save copy" operation. Instead, use [method save_copy].
## func _on_copy_button_up() -> void:
##     Log.popup_state = !Log.popup_state
## [/codeblock]
func complete_copy() -> void: 
	if !Engine.is_editor_hint():
		popup_state = false
		var _timestamp : String = str("[", Time.get_time_string_from_system(use_utc), "] ") 

		if !session_status:
			if error_reporting != 2 and !disable_entry_warning: push_warning("GoLogger Warning: Attempt to log entry failed due to inactive session.")
			return
		else:
			for i in range(categories.size()):
				var _fr = FileAccess.open(categories[i].current_filepath, FileAccess.READ)
				if !_fr:
					popup_errorlbl.text = str("[outline_size=8][center][color=#e84346][pulse freq=4.0 color=#ffffffa1 ease=-1.0]Failed to open base file: ", categories[i].current_file," [/pulse]")
					popup_errorlbl.visible = true
					await get_tree().create_timer(4.0).timeout
					return
				var _c = _fr.get_as_text()
				var _path := str(base_directory, categories[i].category_name, "_Gologs/saved_logs/", get_file_name(copy_name))
				var _fw = FileAccess.open(_path, FileAccess.WRITE)
				if !_fw:
					popup_errorlbl.text = str("[outline_size=8][center][color=#e84346][pulse freq=4.0 color=#ffffffa1 ease=-1.0]Failed to create copy file: ", _path," [/pulse]")
					popup_errorlbl.visible = true
					await get_tree().create_timer(4.0).timeout
					return
				_fw.store_line(str(_c, "\nSaved copy of ", categories[i].current_file, "."))
				_fw.close()
			if print_session_changes == 1 or print_session_changes == 3:
				print(str("GoLogger: Saved persistent copies of current file(s) into 'saved_logs' sub-folder using the name ", copy_name, "."))
			copy_name = ""
			popup_textedit.text = ""



## Stops the current session. Preventing further entries to be logged. In order to log again, a new session must be started using [method start_session] which creates a new categories.[br]
## [param include_timestamp] enables you to turn on and off the date/timestamp with your entries.[br]
func stop_session(include_timestamp : bool = true) -> void:
	if !Engine.is_editor_hint():
		if print_session_changes == 1 or print_session_changes == 3:
			print("GoLogger: Session stopped!")
		var _timestamp : String = str("[", Time.get_time_string_from_system(use_utc), "] Stopped log session.")

		if session_status:
			for i in range(categories.size()):
				var _f = FileAccess.open(categories[i].current_filepath, FileAccess.READ)
				if !_f and error_reporting != 2:
					var _err = FileAccess.get_open_error()
					if _err != OK: push_warning("GoLogger Error: Attempting to stop session by reading file (", categories[i].current_filepath, ") -> Error[", _err, "]")
				var _content := _f.get_as_text()
				_f.close()
				var _fw = FileAccess.open(categories[i].current_filepath, FileAccess.WRITE)
				if !_fw and error_reporting != 2:
					var _err = FileAccess.get_open_error()
					if _err != OK: 
						push_warning("GoLogger Error: Attempting to stop session by writing to file (", categories[i].current_filepath, ") -> Error[", _err, "]")
						return
				var _s := str(_content, str(_timestamp + "Stopped Log Session.") if include_timestamp else "Stopped Log Session.")
				_fw.store_line(_s)
				_fw.close()
				categories[i].current_file = ""
				categories[i].current_filepath = ""
				categories[i].entry_count = 0
			if print_session_changes == 1 or print_session_changes == 4: print("GoLogger: Stopped log session.")
		session_status = false
#endregion



#region Helper functions
## Helper function that returns an appropriate log header string depending on [param log_header].
func get_header() -> String:
	match log_header:
		0: # Project name + version
			return str(
				ProjectSettings.get_setting("application/config/name") + " " if ProjectSettings.get_setting("application/config/name") != "" else "",
				ProjectSettings.get_setting("application/config/version") + " " if ProjectSettings.get_setting("application/config/version") != "" else "")
		1: # Project name
			return str(ProjectSettings.get_setting("application/config/name") + " " if ProjectSettings.get_setting("application/config/name") != "" else "")
		2: # Project version
			return str(ProjectSettings.get_setting("application/config/name") + " " if ProjectSettings.get_setting("application/config/name") != "" else "")
	return ""


## Helper function that determines whether or not any [param category_name] was found more than once in [param categories].
func check_filename_conflicts() -> String:
	var seen_resources : Array[String] = []
	for r in categories:
		if !seen_resources.is_empty():
			if r.category_name in seen_resources:
				return r.category_name # Conflict found -> return the conflicting name for assert error 
			else: seen_resources.append(r.category_name)
		else: seen_resources.append(r.category_name)
	return ""# If no conflicts found -> return empty string and resume execution


## Helper function that returns an error string for likely [DirAccess] and [FileAccess] errors.
func get_err_string(error_code : int) -> String:
	match error_code:
		1: # Failed
			return "Error[12]: Generic error occured, unknown cause."
		4: # Unauthorized
			return "Error[12]: Not authorized to open categories."
		7: # Not found
			return "Error[12]: FIle not found."
		8: # Bad path
			return "Error[8]: Incorrect path."
		10: # No file permission
			return "Error[10]: No permission to access categories."
		11: # File in use
			return "Error[11]: File already in use(forgot to use 'close()'?)."
		12: # Can't open file
			return "Error[12]: Can't open categories."
		13: # Can't write
			return "Error[13]: Can't write to categories."
		14: # Can't read
			return "Error[14]: Can't read categories."
		15: # Unrecognized file
			return "Error[15]: Unrecognized categories."
		16: #  Corrupt
			return "Error[16]: File is corrupted."
	return "Error[X]: Unspecified error."


## Helper function that returns a file name string for your log containing using the prefix entered and adds the current system date and time.[br]
## This should be called with a [LogFileResource]'s [param category_name]. For example [code]get_file_name(categories[0].category_name)[/code]
## [color=red]WARNING: [color=white]Change this at your own discretion! Removing the "0" from single ints("09") will cause sorting issues > May result in improper file deletion.
func get_file_name(prefix_name : String) -> String:
	var dict  : Dictionary = Time.get_datetime_dict_from_system()
	var yy  : String = str(dict["year"]).substr(2, 2) # Removes 20 from 2024
	# Add 0 to single-numbered dates and times
	var mm  : String = str(dict["month"]  if dict["month"]  > 9 else str("0", dict["month"]))
	var dd  : String = str(dict["day"]    if dict["day"]    > 9 else str("0", dict["day"]))
	var hh  : String = str(dict["hour"]   if dict["hour"]   > 9 else str("0", dict["hour"]))
	var mi  : String = str(dict["minute"] if dict["minute"] > 9 else str("0", dict["minute"]))
	var ss  : String = str(dict["second"] if dict["second"] > 9 else str("0", dict["second"]))
	# Format the final string
	var fin : String 
	# Result > "prefix(yy-mm-dd_hh-mm-ss).log"   OR   "prefix(yymmdd_hhmmss.log)
	fin = str(prefix_name, "(", yy, "-", mm, "-", dd, "_", hh, "-", mi, "-", ss, ").log") if dash_timestamp_separator else str(prefix_name, "(", yy, mm, dd, "_", hh,mi, ss, ").log")
	return fin 


## Helper function which returns the contents of the current/newest .log file in the given folder. Can be used to fetch .log contents.
func get_file_contents(folder_path : String) -> String:
	var dir = DirAccess.open(folder_path)
	if !dir:
		var err = DirAccess.get_open_error()
		if err != OK:
			return str("GoLogger Error: Attempting to open directory (", folder_path, ") to find player.log") if error_reporting != 2 else ""
	else:
		var _files = dir.get_files()
		if _files.size() == 0:
			return str("GoLogger Error: No files found in directory (", folder_path, ").") if error_reporting != 2 else ""
		var _newest_file = folder_path + "/" + _files[_files.size() - 1]
		var _fr = FileAccess.open(_newest_file, FileAccess.READ)
		if _fr == null:
			var _err = FileAccess.get_open_error()
			return str("GoLogger Error: Attempting to read .log file -> Error[", _err, "].") if error_reporting != 2 else ""
		var contents = _fr.get_as_text()
		_fr.close()
		return contents
	return str("GoLogger Error: Unable to retrieve file contents in (", folder_path, ")") if error_reporting != 2 else ""



## Adds actions and events to [InputMap]. This only adds it for the runtime instance, meaning it doesn't clutter the [InputMap].
func add_hotkeys() -> void:
	# Start session
	if !InputMap.has_action("GoLogger_start_session"):
		InputMap.add_action("GoLogger_start_session")
	
	if InputMap.action_get_events("GoLogger_start_session").is_empty():
		InputMap.action_add_event("GoLogger_start_session", hotkey_start_session)
	
	# Copy session
	if !InputMap.has_action("GoLogger_copy_session"):
		InputMap.add_action("GoLogger_copy_session")
	
	if InputMap.action_get_events("GoLogger_copy_session").is_empty():
		InputMap.action_add_event("GoLogger_copy_session", hotkey_start_session)
	
	# Stop session
	if !InputMap.has_action("GoLogger_stop_session"):
		InputMap.add_action("GoLogger_stop_session")
	
	if InputMap.action_get_events("GoLogger_stop_session").is_empty():
		InputMap.action_add_event("GoLogger_stop_session", hotkey_stop_session)
	
	# Controller toggle
	if !InputMap.has_action("GoLogger_controller_toggle"):
		InputMap.add_action("GoLogger_controller_toggle")
	
	if InputMap.action_get_events("GoLogger_controller_toggle").is_empty():
		InputMap.action_add_event("GoLogger_controller_toggle", hotkey_controller_toggle)
#endregion



#region Signal listeners
## Uses [param limit_action] to determine which action should be taken when [param session_timer] timeout occurs. 
func _on_session_timer_timeout() -> void:
	match limit_method:
		0: # Entry count limit
			pass
		1: # Session Timer
			if limit_action == 0: # Stop & Start
				stop_session()
				start_session()
			else: # Stop only
				stop_session()
		2: # Both Count limit + Session timer
			if limit_action == 0: # Stop & Start
				stop_session()
				start_session()
			else: # Stop only
				stop_session()
		3: # None
			pass
	session_timer.wait_time = session_timer_wait_time



func _on_text_edit_text_changed() -> void:
	var tx = popup_textedit.text
	var max_char = 20
	if tx != "":
		popup_yesbtn.disabled = false
		if popup_textedit.get_line_count() > 1:
			popup_textedit.text = popup_textedit.get_line(0)
			popup_textedit.set_caret_column(popup_textedit.text.length())
		if popup_textedit.text.length() > max_char:
			popup_textedit.text = popup_textedit.text.substr(0, max_char)
			popup_textedit.set_caret_column(popup_textedit.text.length())
		copy_name = popup_textedit.text



func _on_no_button_button_up() -> void:
	popup_state = false
	popup_textedit.text = ""



func _on_yes_button_button_up() -> void:
	complete_copy()

#endregion
