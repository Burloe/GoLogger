extends Node

#region Documentation & Declarations
## Autoload containing the entire framework that makes up the framework. 
##
## The GitHub repository [url]https://github.com/Burloe/GoLogger[/url] will always have the latest version of 
## GoLogger to download. For installation, setup and how to use instructions, see the README.md or in the Github 
## repo.[br][br] This framework will create folders for each log category in the directory specified in 
## [param base_directory] in which .log files are created. You can add however many log categories you want by 
## adding more [LogFileResource]s into the arrray [param categories]. This plugin uses 'sessions' to indicate 
## when it's logging and each session creates one .log file. To use this plugin, there are four main functions 
## when using this plugin which can be called from any script in your project:[br][br][method start_session]: 
## Starts a session and creates a .log file. When [param autostart_session] is enabled, the plugin calls this 
## function by itself when running your project.[br][method entry]: Main bread and butter of this plugin. Call 
## this in your code to log entries into the .log file. In order to log an entry into different categories, 
## you specify the category by the category's array position in [param categories].[codeblock]
## Log.entry("My first game log entry", 0) # Logs entry into category 0 named 'game'.
## Log.entry("My first game log entry") # Alternative. Not specifying the category will log into category 0.
## Log.entry("My first player log entry", 1) # Log entry into category 1 named 'player[/codeblock]
## [method save_copy]: Copies the active session log into a separate .log file that's saved into 
## [code]base_directory/categoryname_Gologs/saved_logs/[/code]. 
## Files saved into the subfolder are exempt from being deleted. This plugin will delete the oldest entry when 
## the number of logs exceeds [param file_cap] so log files aren't created endlessly.[br][method stop_session]: 
## Stops the active session and stops logging to the corresponding .log file.

## Emitted when a log session has started.
signal session_started 

## Emitted when a log session has been stopped.
signal session_stopped

## Emitted when the session status has changed.  
signal session_status_changed 

## Emitted when the [param session_timer] is started. Useful to sync up sessions with systems/features for other 
## applications than simple file management. E.g. when stress testing some system or feather or to log for a 
## specific time.
signal session_timer_started  



## Path to settings.ini file. This path is a contant and doesn't change if you set your own [param base_directory]
const PATH = "user://GoLogger/settings.ini"

# [ConfigFile] object that settings from 'settings.ini' is loaded into
var config = ConfigFile.new()

## Set the base filepath where folders for each log category are created. For each [LogFileResource] within 
## [param file], a corresponding folder is created where the logs are stored.[br][color=red][b]Warning:
## [/b][br]Changing this parameter at runtime will likely cause errors.
var base_directory : String = "user://GoLogger/"

## Array containing category data that each corresponds to a log category. They define the category name.
@export var categories : Array =[]


## Contains the resulting string as determined by [param log_header].
var header_string : String

@onready var elements_canvaslayer : CanvasLayer = %GoLoggerElements

## Timer node that tracks the session time. Will stop and start new sessions on [signal timeout].
@onready var session_timer : Timer = $SessionTimer

## Default length of time for a session when [param Session Timer] is enabled.
# var session_duration : float = 600.0:
# 	set(new):
# 		session_duration = new
# 		if session_timer != null: session_timer.wait_time = session_duration


## Flags whether or not a session is active.
var session_status : bool = false: 
	set(value):
		session_status = value
		session_status_changed.emit()


## Hotkey used to start session manually. Default hotkey: [kbd]Ctrl + Shift + O[/kbd]
var hotkey_start_session: InputEventShortcut = preload("res://addons/GoLogger/StartSessionShortcut.tres")
## Hotkey used to stop session manually. Default hotkey: [kbd]Ctrl + Shift + P[/kbd]
var hotkey_stop_session	: InputEventShortcut = preload("res://addons/GoLogger/StopSessionShortcut.tres")			
## Hotkey used to save the currently active session with a unique filename. Default hotkey: [kbd]Ctrl + Shift + U[/kbd]
var hotkey_copy_session : InputEventShortcut = preload("res://addons/GoLogger/CopySessionShortcut.tres") 



# Popup
@onready var popup 				: CenterContainer = %Popup
@onready var popup_line_edit 	: LineEdit = 		%CopyNameLineEdit
@onready var popup_yesbtn 		: Button = 			%PopupYesButton
@onready var popup_nobtn 		: Button =			%PopupNoButton
@onready var popup_errorlbl 	: RichTextLabel = 	%PopupErrorLabel

## When true, this bool activates the popup prompt that allows you to enter a file copy name. 
var popup_state : bool = false: 
	set(value):
		if session_status:
			popup_state = value
			popup.visible = value
			popup_line_edit.editable = value
			popup_nobtn.disabled  = !value
			if value:
				popup_line_edit.focus_mode = Control.FOCUS_ALL
				popup_yesbtn.focus_mode   = Control.FOCUS_ALL
				popup_nobtn.focus_mode    = Control.FOCUS_ALL
				popup_line_edit.grab_focus()
			else:
				popup_line_edit.release_focus()
				popup_line_edit.focus_mode = Control.FOCUS_NONE
				popup_yesbtn.focus_mode   = Control.FOCUS_NONE
				popup_nobtn.focus_mode    = Control.FOCUS_NONE

## When saving  file copies of the current session, the entered name is stored in this variable.
var copy_name : String = "" 
#endregion


func _input(event: InputEvent) -> void:
	if !Engine.is_editor_hint():
		if event is InputEventKey \
		or event is InputEventJoypadButton \
		or event is InputEventJoypadMotion and event.axis == 4 \
		or event is InputEventJoypadMotion and event.axis == 5: # Only allows trigger axis
			if hotkey_start_session.shortcut.matches_event(event) and event.is_released():
				start_session()
			if hotkey_stop_session.shortcut.matches_event(event) and event.is_released():
				stop_session()
			if hotkey_copy_session.shortcut.matches_event(event) and event.is_released():
				save_copy()

	
		if event is InputEventKey and event.keycode == KEY_E and event.is_released():
			entry("[Test entry start        Test entry end]", 0)


func _ready() -> void:
	config.load(PATH)
	base_directory = config.get_value("plugin", "base_directory")
	header_string = get_header()
	elements_canvaslayer.layer = get_value("canvaslayer_layer")
	session_timer.autostart = get_value("autostart_session")


	popup_line_edit.text_changed.connect(_on_line_edit_text_changed)
	popup_line_edit.text_submitted.connect(_on_line_edit_text_submitted)
	popup.visible = popup_state
	popup_errorlbl.visible = false
	assert(check_filename_conflicts() == "", str("GoLogger Error: Conflicting category_name '", check_filename_conflicts(), "' found more than once in LogFileResource. Please assign a unique name to all LogFileResources in the 'categories' array."))
	if get_value("autostart_session"):
		start_session()
	add_hotkeys()



## Creates a settings.ini file.
func create_settings_file() -> void:
	var _a : Array[Array] = [["game", 0, "null", "null", 0, true], ["player", 1, "null", "null", 0, true]]
	config.set_value("plugin", "base_directory", "user://GoLogger/")
	config.set_value("plugin", "categories", _a)

	config.set_value("settings", "log_header", 0)
	config.set_value("settings", "canvaslayer_layer", 5)
	config.set_value("settings", "autostart_session", true)
	config.set_value("settings", "timestamp_entries", true)
	config.set_value("settings", "use_utc", false)
	config.set_value("settings", "dash_separator", false)
	config.set_value("settings", "limit_method", 0)
	config.set_value("settings", "entry_count_action", 0)
	config.set_value("settings", "session_timer_action", 0)
	config.set_value("settings", "file_cap", 10)
	config.set_value("settings", "entry_cap", 300)
	config.set_value("settings", "session_duration", 300.0)
	config.set_value("settings", "error_reporting", 0)
	config.set_value("settings", "session_print", 0)
	config.set_value("settings", "disable_warn1", false)
	config.set_value("settings", "disable_warn2", false) 
	var _s = config.save(PATH)
	if _s != OK:
		var _e = config.get_open_error()
		printerr(str("GoLogger error: Failed to create settings.ini file! ", get_error(_e, "ConfigFile")))


##DEPRECATED Validates settings by ensuring their type are correct when loading them.
func validate_settings() -> bool:
	var faults : int = 0
	var expected_types = {
		"plugin/base_directory": TYPE_STRING,
		"plugin/categories": TYPE_ARRAY,
		
		"settings/log_header": TYPE_INT,
		"settings/canvaslayer_layer": TYPE_INT,
		"settings/autostart_session": TYPE_BOOL,
		"settings/timestamp_entries": TYPE_BOOL,
		"settings/use_utc": TYPE_BOOL,
		"settings/dash_separator": TYPE_BOOL,
		"settings/limit_method": TYPE_INT,
		"settings/limit_action": TYPE_INT,
		"settings/file_cap": TYPE_INT,
		"settings/entry_cap": TYPE_INT,
		"settings/session_duration": TYPE_FLOAT,
		"settings/error_reporting": TYPE_INT,
		"settings/session_print": TYPE_INT,
		"settings/disable_warn1": TYPE_BOOL,
		"settings/disable_warn2": TYPE_BOOL
	}
	var types : Array[String] = [
		"Nil",           
		"Bool",          
		"Integer",       
		"Float",         
		"String",        
		"Vector2",       
		"Vector2i",      
		"Rect2",         
		"Rect2i",        
		"Vector3",       
		"Vector3i",      
		"Transform2D",   
		"Plane",         
		"Quaternion",    
		"AABB",          
		"Basis",         
		"Transform3D",   
		"Color",         
		"StringName",    
		"NodePath",      
		"RID",           
		"Object",        
		"Callable",      
		"Signal",        
		"Dictionary",    
		"Array",         
		"PackedByteArray",   
		"PackedInt32Array",  
		"PackedInt64Array",  
		"PackedFloat32Array",
		"PackedFloat64Array",
		"PackedStringArray", 
		"PackedVector2Array",
		"PackedVector3Array",
		"PackedColorArray"   
	]
	var faulty_setting = []
	var faulty_type = []
	for setting_key in expected_types.keys(): 
		var splits = setting_key.split("/") 
		var expected_type = expected_types[setting_key]
		var value = config.get_value(splits[0], splits[1])

		if typeof(value) != expected_type:
			push_warning(str("Gologger Error: Validate settings failed. Invalid type for setting '", splits[1], "'. Expected ", types[expected_type], " but got ", types[value], "."))
			faults += 1
	return faults == 0


## DEPRECATED - Returns any setting value from 'settings.ini'. Also preforms some crucial error checks, pushes errors and creates 
## a default .ini file if one doesn't exist.
func get_value(value : String) -> Variant:
	var _config = ConfigFile.new()
	var _result = _config.load(PATH)
	var section : String = "settings" 
	
	if !FileAccess.file_exists(PATH):
		push_warning(str("GoLogger Warning: No settings.ini file present in ", PATH, ". Generating a new file with default settings."))
		create_settings_file()
	
	if _result != OK:
		push_error(str("GoLogger Error: ConfigFile failed to load settings.ini file."))
		return null
	
	if value == "base_directory" or value == "categories":
		section = "plugin"

	var _val = _config.get_value(section, value)
	if _val == null:
		push_error(str("GoLogger Error: ConfigFile failed to load settings value from file."))
	return _val



#region Main Plugin Functions
## Initiates a log session, recording user defined game events in the .log categories.
## [br][param start_delay] can be used to prevent log files with the same timestamp from being generated, but 
## requires function to be called using the "await" keyword: [code]await Log.start_session(1.0)[/code]. See 
## README[Starting and stopping sessions] for more info.[br]Example usage:[codeblock]
##	Log.start_session()                       # Normal call
##	await Log.start session(1.2)              # Calling with a start delay[/codeblock]
func start_session(start_delay : float = 0.0) -> void:
	#?                         0               1           2               3                  4              5            6
	#? Category array = [category name, category index, current file name, current filepath, file count, entry count, is locked]
	categories = config.get_value("plugin", "categories")
	if categories.is_empty(): 
		push_warning(str("GoLogger warning: Unable to start a session. No valid log categories have been added."))
		return
	
	if start_delay > 0.0:
		await get_tree().create_timer(start_delay).timeout
	if get_value("limit_method") == 1 or get_value("limit_method") == 2:
		session_timer.start(get_value("session_duration"))
		session_timer_started.emit()
	if get_value("session_print") == 1 or get_value("session_print") == 3:
		print("GoLogger: Session started!")


	# Iterate over each LogFileResource in [param categories] array > Create directories and files 
	for i in range(categories.size()): 

		categories[i][3] = get_file_name(categories[i][0])
		var _path : String = str(base_directory, categories[i][0], "_Gologs/") # Result: user://GoLogger/category_GoLogs
		if _path == "": 
			if get_value("error_reporting") == 0: 
				push_error(str("GoLogger Error: Failed to start session due to invalid directory path(", categories[i][3], "). Please assign a valid directory path."))
			if get_value("error_reporting") == 1:
				push_warning(str("GoLogger Error: Failed to start session due to invalid directory path(", categories[i][3], "). Please assign a valid directory path."))
			return
		if session_status:
			if get_value("error_reporting") != 2 and !get_value("disable_warn1"):
				push_warning("GoLogger Warning: Failed to start session, a session is already active.")
			return

		else:
			var _dir : DirAccess
			if !DirAccess.dir_exists_absolute(_path):
				DirAccess.make_dir_recursive_absolute(_path) 
			if !DirAccess.dir_exists_absolute(str(_path, "saved_logs/")):
				DirAccess.make_dir_recursive_absolute(str(_path, "saved_logs/"))

			_dir = DirAccess.open(_path)
			if !_dir and get_value("error_reporting") != 2:
				var _err = DirAccess.get_open_error()
				if _err != OK: push_warning("GoLogger Error: ", get_error(_err, "DirAccess"), " (", _path, ").")
				return
			else:
				 
				# Assign file name
				categories[i][2] = get_file_name(categories[i][0]) 
				# Assign file path
				categories[i][3] = str(_path, categories[i][2]) 
				
				var _f = FileAccess.open(categories[i][3], FileAccess.WRITE)
				var _files = _dir.get_files() 
				#TODO Check if files are .log files > add them to an array and use that to detect/delete files 
				categories[i][4] = _files.size()

				#! Added this feature to disable file count by setting value to 0. Need to test if this actually works.
				#TODO Check that setting file cap to 0 works 
				if get_value("file_cap") > 0:
					while _files.size() > get_value("file_cap") -1:
						_files.sort()
						_dir.remove(_files[0])
						_files.remove_at(0)
						var _err = DirAccess.get_open_error()
						if _err != OK and get_value("error_reporting") != 2: push_warning("GoLoggger Error: Failed to remove old log file -> ", get_error(_err, "DirAccess"))
				#! Unindent the while loop and delete the 'if' line to revert this change
				
				if !_f and get_value("error_reporting") != 2: push_warning("GoLogger Error: Failed to create log file(", categories[i][3], ").")
				else:
					var _s := str(header_string, categories[i][0], " Log session started[", Time.get_datetime_string_from_system(get_value("use_utc"), true), "]:")
					_f.store_line(_s)
					categories[i][5] = 0
				_f.close()
	config.set_value("plugin", "categories", categories)
	config.save(PATH)
	if get_value("session_print") == 1 or get_value("session_print") == 2: print("GoLogger: Started session.")
	session_status = true
	session_started.emit()


## Stores a log entry into the a .log file. You can add data to the log entry(as long as the data 
## can be converted into a string) and specify which category the entry should be store in.[br][br] 
## [param category_index] determine which log category this entry will be stored in. The category_index 
## index corresponds to the order of [LogFileResource] entries in the [param categories] array. Note 
## that leaving this parameter undefined will store the entry in category of when the entry was added 
## to your log.[br][br]Example usage:[codeblock]
## Log.entry(str("Player healed for ", item.heal_amount, "HP by consuming", item.item_name, "."), 1)
## # Resulting log entry stored in category 1: [16:34:59] Player healed for 55HP by consuming Medkit.[/codeblock]
func entry(log_entry : String, category_index : int = 0) -> void:
	#?                         0               1           2               3                  4              5            6
	#? Category array = [category name, category index, current file name, current filepath, file count, entry count, is locked]
	categories = config.get_value("plugin", "categories")
	var _timestamp : String = str("[", Time.get_time_string_from_system(get_value("use_utc")), "] ")
	
	#region Error Check
	# Error check: Valid category and name 
	if categories == null or categories.is_empty():
		if get_value("error_reporting") != 2: 
			printerr("GoLogger Error: No valid categories to log in.")
		return
			
	if categories[category_index][0] == "": 
		if get_value("error_reporting") != 2:
			printerr("GoLogger Error: Attempted to log on a nameless category.")
	
	# Error check: Proper session_status 
	if !session_status:
		if get_value("error_reporting") != 2 and !get_value("disable_warn2"): push_warning("GoLogger Warning: Failed to log entry due to inactive session.")
		return
	#endregion
	

	#? Open directory of the category
	var _f = FileAccess.open(categories[category_index][3], FileAccess.READ) 
	if !_f: # Error check 
		var _err = FileAccess.get_open_error()
		if _err != OK and get_value("error_reporting") != 2: 
			push_warning("Gologger Error: Log entry failed [", get_error(_err, "FileAccess"), ".")
		return 
	
	
	#? Store old entries before the file is truncated
	var lines : Array[String] = [] 
	while not _f.eof_reached():
		var _l = _f.get_line().strip_edges(false, true)
		if _l != "":
			lines.append(_l) 
	_f.close()

	#? Remove old entries at line 1 until entry count is < limit.
	if get_value("limit_method") == 0 or get_value("limit_method") == 2:
		while lines.size() >= (get_value("entry_cap") - 1):
			lines.remove_at(1)# Keep header line at 0
	
	categories[category_index][5] = lines.size() 
	

	#? Open file with write and store the new entry
	var _fw = FileAccess.open(categories[category_index][3], FileAccess.WRITE) 
	if !_fw:
		var err = FileAccess.get_open_error()
		if err != OK and get_value("error_reporting") != 2: 
			push_warning("GoLogger error: Log entry failed. ", get_error(err, "FileAccess"), "")
	
	#? Write lines back into file sequentially
	for line in lines:
		_fw.store_line(str(line))

	#? Add the new entry at end
	var _entry : String = str("\n\t", _timestamp, log_entry) if get_value("timestamp_entries") else str("\t", log_entry)
	_fw.store_line(_entry)
	
	_fw.store_line(str(_entry))
	_fw.close() 


## Initiates the "save copy" operation by displaying the popup prompt. Once a name has been entered and confirmed. [method complete_copy] is called.
func save_copy() -> void:
	popup_state = !popup_state


## Saves the actual copies of the current log session in "saved_logs" sub-folders. [br][b]Note:[br][/b]   
## This function should never be called to perform the "save copy" operation. Instead, use [method save_copy].
## func _on_copy_button_up() -> void:
##     Log.popup_state = !Log.popup_state
## [/codeblock]
func complete_copy() -> void: 
	#?                         0               1           2               3                  4              5            6
	#? Category array = [category name, category index, current file name, current filepath, file count, entry count, is locked]
	popup_state = false
	categories = config.get_value("plugin", "categories")
	# If user entered a name with .log, trim it
	if copy_name.ends_with(".log") or copy_name.ends_with(".txt"):
		copy_name = copy_name.substr(0, copy_name.length() - 4)

	var _timestamp : String = str("[", Time.get_time_string_from_system(get_value("use_utc")), "] ") 

	if !session_status:
		if get_value("error_reporting") != 2 and !get_value("disable_warn2"): push_warning("GoLogger Warning: Attempt to log entry failed due to inactive session.")
		return
	else:
		for i in range(categories.size()):
			var _fr = FileAccess.open(categories[i][3], FileAccess.READ)
			if !_fr:
				popup_errorlbl.text = str("[outline_size=8][center][color=#e84346]Failed to open base of file [", categories[i][3],"].")
				popup_errorlbl.visible = true
				await get_tree().create_timer(4.0).timeout
				return
			var _c = _fr.get_as_text()
			var _path := str(base_directory, categories[i][0], "_Gologs/saved_logs/", get_file_name(copy_name))
			var _fw = FileAccess.open(_path, FileAccess.WRITE)
			if !_fw:
				popup_errorlbl.text = str("[outline_size=8][center][color=#e84346]Failed to create copy of file [", _path,"].")
				popup_errorlbl.visible = true
				await get_tree().create_timer(4.0).timeout
				return
			_fw.store_line(str(_c, "\nSaved copy of ", categories[i][2], "."))
			_fw.close()
		if get_value("session_print") == 1 or get_value("session_print") == 3:
			print(str("GoLogger: Saved persistent copies of current file(s) into 'saved_logs' sub-folder using the name [", copy_name, "]."))
		copy_name = ""
		popup_line_edit.text = ""
	if !session_status:
		if get_value("error_reporting") != 2 and !get_value("disable_warn2"): push_warning("GoLogger Warning: Attempt to log entry failed due to inactive session.")
		return
	else:
		for i in range(categories.size()):
			var _fr = FileAccess.open(categories[i][3], FileAccess.READ)
			if !_fr:
				popup_errorlbl.text = str("[outline_size=8][center][color=#e84346]Failed to open base file: ", categories[i][3],"].")
				popup_errorlbl.visible = true
				await get_tree().create_timer(4.0).timeout
				return
			var _c = _fr.get_as_text()
			var _path := str(base_directory, categories[i][0], "_Gologs/saved_logs/", get_file_name(copy_name))
			var _fw = FileAccess.open(_path, FileAccess.WRITE)
			if !_fw:
				popup_errorlbl.text = str("[outline_size=8][center][color=#e84346]Failed to create copy of file [", _path,".")
				popup_errorlbl.visible = true
				await get_tree().create_timer(4.0).timeout
				return
			_fw.store_line(str(_c, "\nSaved copy of ", categories[i][2], "."))
			_fw.close()
		if get_value("session_print") == 1 or get_value("session_print") == 3:
			print(str("GoLogger: Saved persistent copies of current file(s) into 'saved_logs' sub-folder using the name ", copy_name, "]."))
		copy_name = ""
		popup_line_edit.text = ""
	config.set_value("plugin", "categories", categories)
	config.save(PATH)


## Stops the current session. Preventing further entries to be logged. In order to log again, a new 
## session must be started using [method start_session] which creates a new categories.[br] 
func stop_session() -> void:
	# Category array = [category name, category index, is locked, current file name, current filepath, entry count]
	# 0 = category name
	# 1 = category index
	# 2 = current file name(with timestamp)
	# 3 = current file path
	# 4 = file count
	# 5 = entry count 
	# 6 = is locked
	categories = config.get_value("plugin", "categories")
	if get_value("session_print") == 1 or get_value("session_print") == 3:
		print("GoLogger: Session stopped!")
	var _timestamp : String = str("[", Time.get_time_string_from_system(get_value("use_utc")), "] Stopped log session.")

	if session_status:
		for i in range(categories.size()):
			var _f = FileAccess.open(categories[i][3], FileAccess.READ)
			if !_f and get_value("error_reporting") != 2:
				var _err = FileAccess.get_open_error()
				if _err != OK: push_warning("GoLogger Warning: Failed to open file ", categories[i][3], " with READ ", get_error(_err))
			var _content := _f.get_as_text()
			_f.close()
			var _fw = FileAccess.open(categories[i][3], FileAccess.WRITE)
			if !_fw and get_value("error_reporting") != 2:
				var _err = FileAccess.get_open_error()
				if _err != OK: 
					push_warning("GoLogger Error: Attempting to stop session by writing to file (", categories[i][3], ") -> Error[", _err, "]")
					return
			var _s := str(_content, str(_timestamp + "Stopped Log Session.") if get_value("timestamp_entries") else "Stopped Log Session.")
			_fw.store_line(_s)
			_fw.close()
			categories[i][2] = ""
			categories[i][3] = ""
			categories[i][5] = 0
		if get_value("session_print") == 1 or get_value("session_print") == 4: print("GoLogger: Stopped log session.")
	config.set_value("plugin", "categories", categories)
	config.save(PATH)
	session_status = false
	session_stopped.emit()
#endregion


#region Helper functions
## Helper function that returns an appropriate log header string depending on [param log_header].
func get_header() -> String:
	match get_value("log_header"):
		0: # Project name and version
			var _n = str(ProjectSettings.get_setting("application/config/name"))
			var _v = str(ProjectSettings.get_setting("application/config/version"))
			if _n == "": 
				_n = "Untitled Project"
			if _v == "":  
				_v = "v0.0"
			return str(_n, " v", _v, " ")
		1: # Project name
			var _n = str(ProjectSettings.get_setting("application/config/name"))
			if _n == "": 
				printerr("GoLogger warning: Undefined project name in 'ProjectSettings/application/config/name'.")
				_n = "Untitled Project"
			return str(_n, " ")
		2: # Version
			var _v = str(ProjectSettings.get_setting("application/config/version"))
			if _v == "": 
				printerr("GoLogger warning: Undefined project version in 'ProjectSettings/application/config/version'.")
				_v = "v0.0"
			return str(_v, " ")
		3: # None
			return ""
	return ""

## Helper function that determines whether or not any [param category_name] was found more than once 
## in [param categories].
func check_filename_conflicts() -> String:
	# Category array = [category name, category index, is locked, current file name, current filepath, entry count]
	# 0 = category name
	# 1 = category index
	# 2 = current file name(with timestamp)
	# 3 = current file path
	# 4 = file count
	# 5 = entry count 
	# 6 = is locked 
	categories = config.get_value("plugin", "categories")
	var seen_resources : Array[String] = []
	for r in categories:
		if !seen_resources.is_empty():
			if r[0] in seen_resources:
				return r[0] # Conflict found -> return the conflicting name for assert error 
			else: seen_resources.append(r[0])
		else: seen_resources.append(r[0])
	return ""# If no conflicts found -> return empty string and resume execution


## Returns error string from the error code passed.
static func get_error(error : int, object_type : String = "") -> String:
	match error: 
		1:  return str("Error[1] ",  object_type, " Failed")
		2:  return str("Error[2] ",  object_type, " Unavailable")
		3:  return str("Error[3] ",  object_type, " Unconfigured")
		4:  return str("Error[4] ",  object_type, " Unauthorized")
		5:  return str("Error[5] ",  object_type, " Parameter range")
		6:  return str("Error[6] ",  object_type, " Out of memory")
		7:  return str("Error[7] ",  object_type, " File: Not found")
		8:  return str("Error[8] ",  object_type, " File: Bad drive")
		9:  return str("Error[9] ",  object_type, " File: Bad File path")
		10: return str("Error[10] ", object_type, " No File permission")
		11: return str("Error[11] ", object_type, " File already in use")
		12: return str("Error[12] ", object_type, " Can't open File")
		13: return str("Error[13] ", object_type, " Can't write to File")
		14: return str("Error[14] ", object_type, " Can't read to File")
		15: return str("Error[15] ", object_type, " File unrecognized")
		16: return str("Error[16] ", object_type, " File corrupt")
		17: return str("Error[17] ", object_type, " File missing dependencies")
		18: return str("Error[18] ", object_type, " End of File")
		19: return str("Error[19] ", object_type, " Can't open")
		20: return str("Error[20] ", object_type, " Can't create")
		21: return str("Error[21] ", object_type, " Query failed")
		22: return str("Error[22] ", object_type, " Already in use")
		23: return str("Error[23] ", object_type, " Locked")
		24: return str("Error[24] ", object_type, " Timeout")
		25: return str("Error[25] ", object_type, " Can't connect")
		26: return str("Error[26] ", object_type, " Can't resolve")
		27: return str("Error[27] ", object_type, " Connection error")
		28: return str("Error[28] ", object_type, " Can't acquire resource")
		29: return str("Error[29] ", object_type, " Can't fork process")
		30: return str("Error[30] ", object_type, " Invalid data")
		31: return str("Error[31] ", object_type, " Invalid parameter")
		32: return str("Error[32] ", object_type, " Already exists")
		33: return str("Error[33] ", object_type, " Doesn't exist")
		34: return str("Error[34] ", object_type, " Database: Can't read")
		35: return str("Error[35] ", object_type, " Database: Can't write")
		36: return str("Error[36] ", object_type, " Compilation failed")
		37: return str("Error[37] ", object_type, " Method not found")
		38: return str("Error[38] ", object_type, " Link failed")
		39: return str("Error[39] ", object_type, " Script failed")
		40: return str("Error[40] ", object_type, " Cyclic link")
		41: return str("Error[41] ", object_type, " Invalid declaration")
		42: return str("Error[42] ", object_type, " Duplicate symbol")
		43: return str("Error[43] ", object_type, " Parse error")
		44: return str("Error[44] ", object_type, " Busy error")
		46: return str("Error[45] ", object_type, " Skip error")
		47: return str("Error[46] ", object_type, " Help error")
		48: return str("Error[47] ", object_type, " Bug error")
	return "N/A"

## Helper function that returns a date/timestamped file name for your log containing using the 
## prefix category name.[br]Example usage [code]get_file_name(categories[0][2]})[/code]
## [color=red]WARNING: [color=white]Change this at your own discretion! Removing the "0" from 
## single ints("09") will cause sorting issues > May result in improper file deletion.
func get_file_name(prefix_name : String) -> String:
	var dict  : Dictionary = Time.get_datetime_dict_from_system(get_value("use_utc"))
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
	fin = str(prefix_name, "(", yy, "-", mm, "-", dd, "_", hh, "-", mi, "-", ss, ").log") if get_value("dash_separator") else str(prefix_name, "(", yy, mm, dd, "_", hh,mi, ss, ").log")
	return fin 


## Adds actions and events to [InputMap]. This only adds it for the runtime instance, meaning it 
## doesn't clutter the [InputMap].
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
#endregion



#region Signal listeners
## Uses [param limit_action] to determine which action should be taken when [param session_timer] timeout 
## occurs. 
func _on_session_timer_timeout() -> void:
	if config.get_value("settings", "error_reporting") != 2:
		print("GoLogger: Session timeout!")
	match get_value("limit_method"):
		0: # Entry count limit
			pass
		1: # Session Timer
			if get_value("limit_action") == 0: # Stop & Start
				stop_session()
				start_session()
			else: # Stop only
				stop_session()
		2: # Both Count limit + Session timer
			if get_value("limit_action") == 0: # Stop & Start
				stop_session()
				start_session()
			else: # Stop only
				stop_session()
		3: # None
			pass
	session_timer.wait_time = get_value("session_duration")


func _on_line_edit_text_changed(new_text : String) -> void:
	if new_text != "":
		popup_yesbtn.disabled = false
		popup_line_edit.set_caret_column(popup_line_edit.text.length())
		if new_text.ends_with(".log") or new_text.ends_with(".txt"):
			copy_name = new_text.substr(0, new_text.length() - 4)
		copy_name = popup_line_edit.text
	else:
		popup_yesbtn.disabled = true


func _on_line_edit_text_submitted(new_text : String) -> void:
	if new_text != "":
		if new_text.ends_with(".log") or new_text.ends_with(".txt"):
			copy_name = new_text.substr(0, new_text.length() - 4)
		else:
			copy_name = popup_line_edit.text
		complete_copy()
		popup_line_edit.release_focus()


func _on_no_button_button_up() -> void:
	popup_state = false
	popup_line_edit.text = ""


func _on_yes_button_button_up() -> void:
	complete_copy()

#endregion
