extends Node

## Autoload containing the entire framework that is GoLogger. 
##
## For installation, setup and how to use instructions, see the README.md or https://github.com/Burloe/GoLogger

#region Declarations
signal session_status_changed ## Emitted when the session status has changed.  
signal session_timer_started  ## Emitted when the [param session_timer] is started. Useful for other applications than filemanagement. E.g. when stress testing some system and/or when logging is needed for a specific time. 

# @export_placeholder("game")   var filename1_prefix 	: String = "" ## Use to set a custom filename prefix on file 1. Leave blank to use the default prefix "game". 
# @export_placeholder("player") var filename2_prefix 	: String = "" ## Use to set a custom filename prefix on file 2. Leave blank to use the default prefix "player".
# # These paths can be accessed by selecting Project > Open User Data Folder in the top-left.[br]
# # Normally located in:[br]
# # Windows: %APPDATA%\Godot\app_userdata\[project_name][br]
# # macOS:   ~/Library/Application Support/Godot/app_userdata/[project_name][br]
# # Linux:   ~/.local/share/godot/app_userdata/[project_name]
# @export_placeholder("user://logs/game_Gologs/") var file1_path 	 : String = ""  ## Directory path where game.log files are created/stored. Directory is created if it doesn't exist.
# var current_file1_path 					: String = ""                			## game.log file path associated with the current session.
# var current_file1 						: String = ""                   		## game.log file path associated with the current session.
# @export_placeholder("user://logs/player_Gologs/") var file2_path : String = ""  ## Directory path where player.log files are created/stored. Directory is created if it doesn't exist.
# var current_file2_path 					: String = ""             				## player.log file path associated with the current session.
# var current_file2 						: String = ""                  			## player.log file path associated with the current session.
# @export_placeholder("user://logs/saved_Gologs/") var custom_path : String = ""

@export var file : Array[LogFileResource] = [preload("res://addons/GoLogger/DefaultLogFile.tres")]
@export var separate_timestamps : bool = false ## When enabled, date and timestamps are separated with '-'. Disabled = "prefix_241028_182143.log". Enabled = "prefix_24-10-28_18-21-43.log".

@export_enum("Project name & version", "Project name", "Project version", "None") var log_info_header : int = 0 ## Determines the type of header used in the .log file header. Gets the project name and version from Project Settings > Application > Config.[br][i]"Project X version 0.84 - Game Log session started[2024-09-16 21:38:04]:"
var header_string : String ## Contains the resulting string determined from [param log_info_header].
@export_enum("None", "Start & Stop Session", "Start Session only", "Stop Session only") var print_session_changes : int = 0 ## If true, enables printing messages to the output when a log session is started or stopped.

@export_group("Hotkeys & LogController")
var shortcut_start_session				= preload("res://addons/GoLogger/StartSessionShortcut.tres") ## Use to bind your preferred keybinding to start a session.
@export var hotkey_start_session		: InputEventShortcut = shortcut_start_session 		## Hotkey used to start session manually. Default hotkey: Ctrl + Shift + O

var shortcut_stop_session				= preload("res://addons/GoLogger/StopSessionShortcut.tres") ## Use to bind your preferred keybinding to stop a session.
@export var hotkey_stop_session			: InputEventShortcut = shortcut_stop_session		## Hotkey used to stop session manually. Default hotkey: Ctrl + Shift + P

var shortcut_save_unique_file			= preload("res://addons/GoLogger/SaveUniqueFileShortcut.tres") ## Use to bind your preferred keybinding to save the active session into a unique save file(meaning the file is safe from deletion).
@export var hotkey_save_unique			: InputEventShortcut = shortcut_save_unique_file	## Hotkey used to save the currently active session with a unique filename(optionally in a unique folder) manually. Default hotkey: Ctrl + Shift + U

var shortcut_toggle_controller			= preload("res://addons/GoLogger/ToggleControllerShortcut.tres") ## Use to bind your preferred keybinding to toggle visibility of GoLoggerController.
@export var hotkey_toggle_controller	: InputEventShortcut = shortcut_toggle_controller 	## Shortcut binding used to toggle the controller's visibility(supports joypad bindings).


@export var hide_contoller_on_start		: bool = false                      	## Hides GoLoggerController when running your project. Use F9(by default) to toggle visibility.
@export var controller_drag_offset		: Vector2 = Vector2(0, 0)             	## The offset used to correct the controller window position while dragging(may require changing depending on your project resolution and scaling).


@export_group("Error Reporting Options")
@export_enum("All", "Only Warnings", "None") var error_reporting : int = 0 		## Enables/disables all debug warnings and errors.[br]'All' - Enables errors and warnings.[br]'Only Warnings' - Disables errors and only allows warnings.[br]'None' - All errors and warnings are disabled.

@export var autostart_session 			: bool = true            				## Autostarts the session at runtime.

@export var disable_session_warning 	: bool = false    						## Disables the "Attempted to start new log session before stopping the previous" warning.

@export var disable_entry_warning 		: bool = false       					## Disables the "Attempt to log entry failed due to inactive session" warning.
var session_status						: bool = false:                      	## Flags whether or not a session is active.
	set(value):
		session_status = value
		session_status_changed.emit()

@export_category("Log Management") 
@export var file_cap 					: int = 10 ## Sets the max number of log files. Deletes the oldest log file in directory when file count exceeds this number.

## Denotes the log management method used to prevent long or large .log files. Added to combat potential performance issues.[br]
## [b]1. Entry count Limit:[/b] Checks entry count when logging a new one. If count exceeds [param entry_count_limit], oldest entry is removed to make room for the new entry.[br]
## [b]2. Session Timer:[/b] Upon session is start, [param session_timer] is also started, counting down the [param session_timer_wait_time] value. Upon [signal timeout], session is stopped and the action is determined by [param session_timeout_action].[br]
## [b]3. Entry Count Limit + Session Timer:[/b] Uses both of the above methods.[br]
## [b]4. None:[/b] Uses no methods of preventing too large files. Not recommended, particularly so if you intend to ship your game with GoLogger or a derivation.
@export_enum("Entry Count Limit", "Session Timer", "Entry Limit + Session Timer", "None") var log_manage_method : int = 0

## The log entry count(or line count) limit allowed in the .log file. If entry count exceeds this number, the oldest entry is removed before adding the new.
## [b]Stop & start new session:[/b] Stops the current session and starting a new one.[br][b]Stop session only:[/b] Stops the current session without starting a new one. Note that this requires a manual restart which can be done in the Controller, or if you've implemented your own way of starting it.
@export_enum("Stop & start new session", "Stop session only") var session_timeout_action : int = 0

@export var entry_count_limit			: int = 1500              ## The maximum number of log entries allowed in one file before it starts to delete the oldest entry when adding a new.
var entry_count_game 					: int = 0                         ## The current count of entries in the game.log.
var entry_count_player 					: int = 0                       ## The current count of entries in the player.log.

@onready var session_timer				: Timer = $SessionTimer      ## Timer node that tracks the session time. Will stop and start new sessions on [signal timeout].

@export var session_timer_wait_time 	: float = 600.0:   ## Default length of time for a session when [param Session Timer] is enabled.
	set(new):
		session_timer_wait_time = new
		if session_timer != null: session_timer.wait_time = session_timer_wait_time
#endregion


func _input(event: InputEvent) -> void:
	if event is InputEventKey or InputEventJoypadButton:
		if Log.hotkey_start_session.shortcut.matches_event(event) and event.is_released():
			start_session()
		if Log.hotkey_stop_session.shortcut.matches_event(event) and event.is_released():
			stop_session()
		if Log.hotkey_save_unique.shortcut.matches_event(event) and event.is_released():
			pass


func _ready() -> void:
	hotkey_toggle_controller = shortcut_toggle_controller
	header_string = get_header()	
	if session_timer == null: 
		session_timer = Timer.new()
		add_child(session_timer)
		session_timer.owner = self
		session_timer.set_name("SessionTimer")
	session_timer.timeout.connect(_on_session_timer_timeout)
	session_timer.one_shot = false
	session_timer.wait_time = session_timer_wait_time
	session_timer.autostart = false
	
	if autostart_session:
		start_session()


## Initiates a log session, recording game events in the .log file.
## [br][param start_delay] can be used to prevent log files with the same timestamp from being generated, but requires function to be called using the "await" keyword: [code]await Log.start_session(1.0)[/code].
## See README[Starting and stopping sessions] for more info.[br][param utc] when enabled will use the UTC time when creating timestamps. Leave false to use the user's local system time.[br][param space] will use a space to separate date and time instead of a "T"(from "YY-MM-DDTHH-MM-SS" to "YY-MM-DD HH-MM-SS).[br]Example usage:[codeblock]
##	Log.start_session()                       # Normal call
##	await Log.start session(1.2)              # Calling with a start delay
##	await Log.start_session(1.2, true, false) # Using all redefined parameters
##	# 1. Uses a start delay. 2. UTC time rather than local system time. 3. Uses a T instead of a space to separate date and time in timestamps.[/codeblock]
func start_session(start_delay : float = 0.0, utc : bool = false, space : bool = true) -> void:
	if start_delay > 0.0:
		await get_tree().create_timer(start_delay).timeout
	if log_manage_method == 1 or log_manage_method == 2:
		session_timer.start(session_timer_wait_time)
		session_timer_started.emit()
	if print_session_changes == 1 or print_session_changes == 3:
		print("GoLogger: Session started!")
 

	for i in file.size():
		assert(file[i] != null, str("GoLogger Error: 'file' array entry", i, " has no [LogFileResource] added."))

		var _fname : String
		_fname = get_file_name(file[i].filename_prefix) if file[i].filename_prefix != "" else str("file", i)
		var _path : String = str(file[i].base_directory, file[i].filename_prefix, "_GoLogs/")
		
		if _path == "": 
			if error_reporting == 0: 
				push_error(str("GoLogger Error: Failed to start session due to invalid directory path(", _fname, "). Please assign a valid directory path."))
			if error_reporting == 1:
				push_warning(str("GoLogger Error: Failed to start session due to invalid directory path(", _fname, "). Please assign a valid directory path."))
			return
		if session_status:
			if error_reporting != 2 and !disable_session_warning:
				push_warning("GoLogger Warning: Attempted to start a new log session before stopping the previous session.")
			return
		else:
			var _dir : DirAccess
			if !DirAccess.dir_exists_absolute(_path):
				DirAccess.make_dir_recursive_absolute(_path)
			_dir = DirAccess.open(_path)
			if !_dir and error_reporting != 2:
				var _err = DirAccess.get_open_error()
				if _err != OK: push_warning("GoLogger ", get_err_string(_err), " (", _path, ").")
				return
			else:
				file[i].current_filepath = _path + get_file_name(file[i].filename_prefix)
				file[i].current_file = get_file_name(file[i].filename_prefix)
				printerr("Current File: ",file[i].current_file)
				printerr("Current FilePath: ",file[i].current_filepath)
				var _f = FileAccess.open(file[i].current_filepath, FileAccess.WRITE)
				var _files = _dir.get_files()
				while _files.size() > file_cap:
					_files.sort()
					_dir.remove(_files[0])
					_files.remove_at(0)
					var _err = DirAccess.get_open_error()
					if _err != OK and error_reporting != 2: push_warning("GoLoggger Error: Failed to remove old log file -> ", get_err_string(_err))
				if !_f and error_reporting != 2: push_warning("GoLogger Error: Failed to create log file(", file[i].current_file, ").")
				else:
					var _s := str(header_string, file[i].filename_prefix, " Log session started[", Time.get_datetime_string_from_system(utc, space), "]:")
					_f.store_line(_s)
					file[i].entry_count += 1
					_f.close()
	session_status = true


## Stores a log entry into the 'game/ui/player.log' file.[br]
## [param timestamp] enables you to turn on and off the date/timestamp with your entries.[br]
## [param utc] will force the date/timestamp to use UTC time rather than the user's local system time.[br]Example usage:[codeblock]
## Log.entry(str("Player healed for ", item.heal_amount, "HP by consuming", item.item_name, "."))
## # Resulting log entry: [16:34:59] Player healed for 55HP by consuming Medkit.[/codeblock]
func entry(log_entry : String, file_index : int = 0, include_timestamp : bool = true, utc : bool = false) -> void:
	var _timestamp : String = str("[", Time.get_time_string_from_system(utc), "] ") 

	if !session_status:
		if error_reporting != 2 and !disable_entry_warning: push_warning("GoLogger Warning: Attempt to log entry failed due to inactive session.")
		return
	else:
		var _f = FileAccess.open(file[file_index].current_filepath, FileAccess.READ)
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

				# Remove old entried at line 1 until entry count is less than limit.
				if log_manage_method == 0 or log_manage_method == 2:
					while lines.size() > entry_count_limit:
						lines.remove_at(1)
				file[file_index].entry_count = lines.size()

				var _fw = FileAccess.open(file[file_index].current_filepath, FileAccess.WRITE)
				if !_fw and error_reporting != 2:
					var err = FileAccess.get_open_error()
					if err != OK: push_warning("GoLogger error: Log entry failed due to FileAccess error[", get_err_string(err), "]")
				var _entry : String = str("\t", _timestamp, log_entry) if include_timestamp else str("\t", log_entry)
				_fw.store_line(str(_c, _entry))
				_fw.close()


## Stops the current session. Preventing further entries to be logged. In order to log again, a new session must be started using [method start_session] which creates a new file.[br]
## [param timestamp] enables you to turn on and off the date/timestamp with your entries.[br]
## [param utc] will force the date/timestamp to use UTC time rather than the user's local system time.[br]
func stop_session(include_timestamp : bool = true, utc : bool = false) -> void:
	if print_session_changes == 1 or print_session_changes == 3:
		print("GoLogger: Session stopped!")
	var _timestamp : String = str("[", Time.get_time_string_from_system(utc), "] Stopped log session.")

	if session_status:
		for i in file.size():
			var _f = FileAccess.open(file[i].current_filepath, FileAccess.READ)
			if !_f and error_reporting != 2:
				var _err = FileAccess.get_open_error()
				if _err != OK: push_warning("GoLogger Error: Attempting to stop session by reading file (", file[i].current_filepath, ") -> Error[", _err, "]")
			var _content := _f.get_as_text()
			_f.close()
			var _fw = FileAccess.open(file[i].current_filepath, FileAccess.WRITE)
			if !_fw and error_reporting != 2:
				var _err = FileAccess.get_open_error()
				if _err != OK: 
					push_warning("GoLogger Error: Attempting to stop session by writing to file (", file[i].current_filepath, ") -> Error[", _err, "]")
					return
			var _s := str(_content, str(_timestamp + "Stopped Log Session.") if include_timestamp else "Stopped Log Session.")
			_fw.store_line(_s)
			_fw.close()
			file[i].current_file = ""
			file[i].current_filepath = ""
			file[i].entry_count = 0
	session_status = false


## Helper function that returns the appropriate log header depending on [param log_info_header].
func get_header() -> String:
	match log_info_header:
		0: # Project name + version
			return str(
				ProjectSettings.get_setting("application/config/name") + " " if ProjectSettings.get_setting("application/config/name") != "" else "",
				ProjectSettings.get_setting("application/config/version") + " " if ProjectSettings.get_setting("application/config/version") != "" else "")
		1: # Project name
			return str(ProjectSettings.get_setting("application/config/name") + " " if ProjectSettings.get_setting("application/config/name") != "" else "")
		2: # Project version
			return str(ProjectSettings.get_setting("application/config/name") + " " if ProjectSettings.get_setting("application/config/name") != "" else "")
	return ""

## Helper function to get an error string for likely [DirAccess] and [FileAccess] errors.
func get_err_string(error_code : int) -> String:
	match error_code:
		1: # Failed
			return "Error[12]: Generic error occured, unknown cause."
		4: # Unauthorized
			return "Error[12]: Not authorized to open file."
		7: # Not found
			return "Error[12]: FIle not found."
		8: # Bad path
			return "Error[8]: Incorrect path."
		10: # No file permission
			return "Error[10]: No permission to access file."
		11: # File in use
			return "Error[11]: File already in use(forgot to use 'close()'?)."
		12: # Cannae open file
			return "Error[12]: Can't open file."
		13: # Can't write
			return "Error[13]: Can't write to file."
		14: # Can't read
			return "Error[14]: Can't read file."
		15: # Unrecognized file
			return "Error[15]: Unrecognized file."
		16: #  Corrupt
			return "Error[16]: File is corrupted."
	return "Error[X]: Unspecified error."

## Helper function that returns the string file name for your log containing the current system date and time.[br]
## [color=red]WARNING: [color=white]Change this at your own discretion! Removing the "0" from single ints("09") will cause sorting issues > May result in improper file deletion.
func get_file_name(filename : String) -> String:
	var dict  : Dictionary = Time.get_datetime_dict_from_system()
	var yy  : String = str(dict["year"]).substr(2, 2) # Removes 20 from 2024
	# Add 0 to single int dates and times
	var mm  : String = str(dict["month"]  if dict["month"]  > 9 else str("0", dict["month"]))
	var dd  : String = str(dict["day"]    if dict["day"]    > 9 else str("0", dict["day"]))
	var hh  : String = str(dict["hour"]   if dict["hour"]   > 9 else str("0", dict["hour"]))
	var mi  : String = str(dict["minute"] if dict["minute"] > 9 else str("0", dict["minute"]))
	var ss  : String = str(dict["second"] if dict["second"] > 9 else str("0", dict["second"]))
	# Format the final string
	var fin : String 
	# Result > "prefix(yy-mm-dd_hh-mm-ss).log"   OR   "prefix(yymmdd_hhmmss.log)
	fin = str(filename, "(", yy, "-", mm, "-", dd, "_", hh, "-", mi, "-", ss, ").log") if separate_timestamps else str(filename, "(", yy, mm, dd, "_", hh,mi, ss, ").log")
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


## Stops and starts sessions when using the "Session Timer" option with[param session_timeout_action]. 
func _on_session_timer_timeout() -> void:
	match log_manage_method:
		0: # Entry count limit
			pass
		1: # Session Timer
			if session_timeout_action == 0: # Stop & Start
				stop_session()
				start_session()
			else: # Stop only
				stop_session()
		2: # Both Count limit + Session timer
			if session_timeout_action == 0: # Stop & Start
				stop_session()
				start_session()
			else: # Stop only
				stop_session()
		3: # None
			pass
	session_timer.wait_time = session_timer_wait_time