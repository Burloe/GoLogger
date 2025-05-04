extends Node

#region Documentation & Declarations
## Autoload containing the entire framework that makes up the framework. 
##
## The GoLogger Wiki can be found at [url]https://github.com/Burloe/GoLogger/wiki[/url] with information on how to use the plugin, how it works and more information. 
## The GitHub repository [url]https://github.com/Burloe/GoLogger[/url] will always have the latest version of 
## GoLogger to download. For installation, setup and how to use instructions, see the README.md or in the Github 
## repo. 


signal session_started ## Emitted when a log session has started.
signal session_stopped ## Emitted when a log session has been stopped.
signal session_status_changed(changed_to: bool) ## Emitted when the session status has started or stopped.
signal session_timer_started ## Emitted when the [param session_timer] is started.
signal session_timer_stopped ## Emitted when the [param session_timer] is stopped.

const PATH = "user://GoLogger/settings.ini" 
var config := ConfigFile.new()
var base_directory: String = "user://GoLogger/" 
var categories: Array = []
var header_string: String
var copy_name : String = "" 
var session_status: bool = false: 
	set(value):
		session_status = value
		session_status_changed.emit()
		if value: session_started.emit()
		else: session_stopped.emit()

@onready var elements_canvaslayer: CanvasLayer = %GoLoggerElements 
@onready var session_timer: Timer = %SessionTimer 
@onready var popup: CenterContainer = %Popup
@onready var popup_line_edit: LineEdit = %CopyNameLineEdit
@onready var popup_yesbtn: Button = %PopupYesButton
@onready var popup_nobtn: Button = %PopupNoButton
@onready var prompt_label: RichTextLabel = %PromptLabel
@onready var popup_errorlbl: RichTextLabel = %PopupErrorLabel
@onready var inaction_timer: Timer = %InactionTimer
var popup_state : bool = false: 
	set(value):
		popup_state = value
		if session_status:
			toggle_copy_popup(value)

## Hotkey used to start session manually. Default hotkey: [kbd]Ctrl + Shift + O[/kbd]
var hotkey_start_session: InputEventShortcut = preload("res://addons/GoLogger/StartSessionShortcut.tres")
## Hotkey used to stop session manually. Default hotkey: [kbd]Ctrl + Shift + P[/kbd]
var hotkey_stop_session: InputEventShortcut = preload("res://addons/GoLogger/StopSessionShortcut.tres")			
## Hotkey used to save the currently active session with a unique filename. Default hotkey: [kbd]Ctrl + Shift + U[/kbd]
var hotkey_copy_session: InputEventShortcut = preload("res://addons/GoLogger/CopySessionShortcut.tres") 
#endregion



func _input(event: InputEvent) -> void:
	if !Engine.is_editor_hint():
		if event is InputEventKey \
		or event is InputEventJoypadButton \
		or event is InputEventJoypadMotion and event.axis == 4 \
		or event is InputEventJoypadMotion and event.axis == 5: # Only allow trigger axis
			if hotkey_start_session.shortcut.matches_event(event) and event.is_released():
				start_session()
			if hotkey_stop_session.shortcut.matches_event(event) and event.is_released():
				stop_session()
			if hotkey_copy_session.shortcut.matches_event(event) and event.is_released():
				save_copy()


func _ready() -> void:
	config.load(PATH)
	base_directory = config.get_value("plugin", "base_directory")
	header_string = get_header()
	elements_canvaslayer.layer = get_value("canvaslayer_layer")
	session_timer.timeout.connect(_on_session_timer_timeout)
	inaction_timer.timeout.connect(_on_inaction_timer_timeout)
	popup_line_edit.text_changed.connect(_on_line_edit_text_changed)
	popup_line_edit.text_submitted.connect(_on_line_edit_text_submitted)
	popup.visible = popup_state
	popup_errorlbl.visible = false
	popup_yesbtn.disabled = true
	
	assert(check_filename_conflicts() == "", str("GoLogger: Conflicting category_name [", check_filename_conflicts(), "] found in two(or more) categories."))
	
	if get_value("autostart_session"):
		start_session()


func _physics_process(_delta: float) -> void:
	if !Engine.is_editor_hint(): 
		if popup_state and inaction_timer != null and !inaction_timer.is_stopped(): 
			prompt_label.text = str("[center]Save copies of the current logs?[font_size=12]\nAutomatically cancelled in ", snapped(inaction_timer.time_left, 1.0),"s!\n[color=lightblue]Limit methods are paused during this prompt.")


## Creates a settings.ini file.
func create_settings_file() -> void:
	var _a : Array[Array] = [["game", 0, "null", "null", 0, 0, false], ["player", 1, "null", "null", 0, 0, false]]
	config.set_value("plugin", "base_directory", "user://GoLogger/")
	config.set_value("plugin", "categories", _a)

	config.set_value("settings", "columns", 6)
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
	config.set_value("settings", "disable_warn1", false)
	config.set_value("settings", "disable_warn2", false) 
	var _s = config.save(PATH)
	if _s != OK:
		var _e = config.get_open_error()
		printerr(str("GoLogger error: Failed to create settings.ini file! ", get_error(_e, "ConfigFile")))


## Validates settings by ensuring their type are correct when loading them. Returns false if valid and true if corrupted.[br]
## This was made to aid development of the plugin but can be used to make sure settings.ini haven't been corrupted.
func validate_settings() -> bool:
	var faults : int = 0
	var expected_types = {
		"plugin/base_directory": TYPE_STRING,
		"plugin/categories": TYPE_ARRAY,
		"settings/columns": TYPE_INT,
		"settings/log_header": TYPE_INT,
		"settings/canvaslayer_layer": TYPE_INT,
		"settings/autostart_session": TYPE_BOOL,
		"settings/timestamp_entries": TYPE_BOOL,
		"settings/use_utc": TYPE_BOOL,
		"settings/dash_separator": TYPE_BOOL,
		"settings/limit_method": TYPE_INT,
		"settings/entry_count_action": TYPE_INT,
		"settings/session_timer_action": TYPE_INT,
		"settings/file_cap": TYPE_INT,
		"settings/entry_cap": TYPE_INT,
		"settings/session_duration": TYPE_FLOAT,
		"settings/error_reporting": TYPE_INT, 
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
	
	for setting_key in expected_types.keys(): 
		var splits = setting_key.split("/") 
		var expected_type = expected_types[setting_key]
		var value = config.get_value(splits[0], splits[1])

		if typeof(value) != expected_type:
			push_warning(str("Gologger Error: Validate settings failed. Invalid type for setting '", splits[1], "'. Expected ", types[expected_type], " but got ", types[value], "."))
			faults += 1
	return faults == 0


## Returns any setting value from 'settings.ini'. Also preforms some crucial error checks, pushes errors and creates 
## a default .ini file if one doesn't exist.
func get_value(value : String) -> Variant:
	var _config = ConfigFile.new()
	var _result = _config.load(PATH)
	var section : String = "settings" 
	
	if !FileAccess.file_exists(PATH):
		push_warning(str("GoLogger: No settings.ini file present in ", PATH, ". Generating a new file with default settings."))
		create_settings_file()
	
	if _result != OK:
		push_error(str("GoLogger: ConfigFile failed to load settings.ini file."))
		return null
	
	if value == "base_directory" or value == "categories":
		section = "plugin"

	var _val = _config.get_value(section, value)
	if _val == null:
		push_error(str("GoLogger: ConfigFile failed to load settings value from file."))
	return _val


#region Main Functions
## Initiates a log session, creating new .log files for each category to log into.
func start_session() -> void: 
	if session_status:
		if get_value("error_reporting") != 2 and !get_value("disable_warn1"):
			push_warning("GoLogger: Failed to start session, a session is already active.")
		return
	
	config.load(PATH)
	categories = config.get_value("plugin", "categories")
	if categories.is_empty(): 
		push_warning(str("GoLogger warning: Unable to start a session. No valid log categories have been added."))
		return
	if get_value("limit_method") == 1 or get_value("limit_method") == 2:
		session_timer.start(get_value("session_duration"))
		session_timer_started.emit() 

	for i in range(categories.size()): 
		categories[i][3] = get_file_name(categories[i][0])
		var _path : String
		if _path.begins_with("res://") or _path.begins_with("user://"):
			_path = str(base_directory, categories[i][0], "_Gologs/")
		else:
			_path = str(base_directory, categories[i][0], "_Gologs/")
		if _path == "": # ERROR CHECK
			if get_value("error_reporting") == 0: 
				push_error(str("GoLogger: Failed to start session due to invalid directory path(", categories[i][3], "). Please assign a valid directory path."))
			if get_value("error_reporting") == 1:
				push_warning(str("GoLogger: Failed to start session due to invalid directory path(", categories[i][3], "). Please assign a valid directory path."))
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
				if _err != OK: push_warning("GoLogger: ", get_error(_err, "DirAccess"), " (", _path, ").")
				return
			else:
				categories[i][2] = get_file_name(categories[i][0])
				categories[i][3] = str(_path, categories[i][2]) 
				var _f = FileAccess.open(categories[i][3], FileAccess.WRITE)
				var _files = _dir.get_files() 
				categories[i][4] = _files.size()
				if get_value("file_cap") > 0:
					while _files.size() > get_value("file_cap") -1:
						_files.sort()
						_dir.remove(_files[0])
						_files.remove_at(0)
						var _err = DirAccess.get_open_error()
						if _err != OK and get_value("error_reporting") != 2: push_warning("GoLoggger Error: Failed to remove old log file -> ", get_error(_err, "DirAccess"))
				if !_f and get_value("error_reporting") != 2: push_warning("GoLogger: Failed to create log file(", categories[i][3], ").")
				else:
					var _s := str(header_string, categories[i][0], " Log session started[", Time.get_datetime_string_from_system(get_value("use_utc"), true), "]:")
					_f.store_line(_s)
					categories[i][5] = 0
				_f.close()

	config.set_value("plugin", "categories", categories)
	config.save(PATH) 
	session_status = true
	if session_timer != null:
		if session_timer.is_stopped() and get_value("session_timer_action") == 1 or session_timer.is_stopped() and get_value("session_timer_action") == 2:
			session_timer.start()
			session_timer_started.emit()
	session_started.emit()


## Stores a log entry into the a .log file. [br]Example usage:[codeblock]
## Log.entry(str("Player healed for ", item.heal_amount, "HP by consuming", item.item_name, "."), 1)[/codeblock]
func entry(log_entry : String, category_index : int = 0) -> void:
	config.load(PATH)
	categories = config.get_value("plugin", "categories")
	var _timestamp : String = str("[", Time.get_time_string_from_system(get_value("use_utc")), "] ")
	
	# Error check: Valid category and name 
	if categories == null or categories.is_empty():
		if get_value("error_reporting") != 2: 
			printerr("GoLogger: No valid categories to log in.")
		return		
	if categories[category_index][0] == "": 
		if get_value("error_reporting") != 2:
			printerr("GoLogger: Attempted to log on a nameless category.")
			return
	if !session_status:
		if get_value("error_reporting") != 2 and !get_value("disable_warn2"): push_warning("GoLogger: Failed to log entry due to inactive session.")
		return
	
	var _f = FileAccess.open(categories[category_index][3], FileAccess.READ) 
	if !_f: # Error check 
		var _err = FileAccess.get_open_error()
		if _err != OK and get_value("error_reporting") != 2: 
			push_warning("Gologger Error: Log entry failed [", get_error(_err, "FileAccess"), ".")
		return 
	
	var lines : Array[String] = [] 
	while not _f.eof_reached():
		var _l = _f.get_line().strip_edges(false, true)
		if _l != "":
			lines.append(_l) 
	_f.close()
	categories[category_index][5] = lines.size()

	if !popup_state:
		match get_value("limit_method"): 
			0: # Entry count
				match get_value("entry_count_action"):
					0: # Remove old entries
						while lines.size() >= get_value("entry_cap"):
							lines.remove_at(1) # Keeping header line 0
					1: # Stop & start
						if lines.size() >= get_value("entry_cap"):
							stop_session()
							start_session()
							entry(log_entry, category_index)
							return
					2: # Stop only
						if lines.size() >= get_value("entry_cap"):
							stop_session()
							return
			1: # Session timer
				match get_value("session_timer_action"):
					0: # Stop & start session
						stop_session()
						start_session()
						entry(log_entry, category_index)
						return
					1: # Stop session 
						stop_session()
						return
			2: # Both Entry count limit and Session Timer
				match get_value("entry_count_action"):
					0: # Stop & start session
						if lines.size() >= get_value("entry_cap"):
							stop_session()
							start_session()
							entry(log_entry, category_index)
							return
					1: # Stop session 
						if lines.size() >= get_value("entry_cap"):
							stop_session()
							return

	categories[category_index][5] = lines.size()
	var _fw = FileAccess.open(categories[category_index][3], FileAccess.WRITE) 
	if !_fw:
		var err = FileAccess.get_open_error()
		if err != OK and get_value("error_reporting") != 2: 
			push_warning("GoLogger error: Log entry failed. ", get_error(err, "FileAccess"), "") 
	for line in lines:
		_fw.store_line(str(line))
	var _entry : String = str("\t", _timestamp, log_entry) if get_value("timestamp_entries") else str("\t", log_entry)
	_fw.store_line(_entry)
	_fw.close() 

## Creates a copied log file of the current session in it's current state at the time it's called.
## You can either call this method programmatically by calling this method and passing in a predetermined name or call it without and use the prompt to enter a name.
## You can also use the hotkey to initiate the prompt at runtime if you ever want to save a copy of the current session.
func save_copy(_name: String = "") -> void:
	if session_status:
		# No specified name -> prompt popup for name
		if _name == "":	
			popup_state = true if popup_state == false else false 
		# Name specified, i.e. called programmatically -> save copy using predetermines name
		else:
			copy_name = _name
			complete_copy()




## Saves the copies after copy prompts is done in "saved_logs" sub-folders.
func complete_copy() -> void:
	if !session_status:
		if get_value("error_reporting") != 2 and !get_value("disable_warn2"): push_warning("GoLogger: Attempt to log entry failed due to inactive session.")
		return

	config.load(PATH)
	categories = config.get_value("plugin", "categories")
	if categories.is_empty():
		if config.get_value("plugin", "error_reporting"):
			push_warning("GoLogger: Unable to complete copy action. No categories are present.")
	
	if copy_name.ends_with(".log") or copy_name.ends_with(".txt"):
		copy_name = copy_name.substr(0, copy_name.length() - 4)
	var _timestamp : String = str("[", Time.get_time_string_from_system(get_value("use_utc")), "] ") 

	for i in range(categories.size()):
		var _fr = FileAccess.open(categories[i][3], FileAccess.READ)
		if !_fr:
			popup_errorlbl.text = str("[outline_size=8][center][color=#e84346]Failed to open base file to copy the session [", categories[i][3],"].")
			popup_errorlbl.visible = true
			await get_tree().create_timer(4.0).timeout
			return
		
		var _c = _fr.get_as_text()
		var _path := str(base_directory, categories[i][0], "_Gologs/saved_logs/", get_file_name(copy_name))
		var _fw = FileAccess.open(_path, FileAccess.WRITE)
		if !_fw: 
			var _e = FileAccess.get_open_error()
			popup_errorlbl.text = str("[outline_size=8][center][color=#e84346]Failed to create copy of file [", _path,"] - ", get_error(_e), ".")
			popup_errorlbl.visible = true
			await get_tree().create_timer(4.0).timeout
			return
		_fw.store_line(str(_c, "\nSaved copy of ", categories[i][2], "."))
		_fw.close()
	config.set_value("plugin", "categories", categories)
	config.save(PATH)
	popup_state = false 
	

## Stops the current session. Preventing further entries to be logged into the file of the current session.
func stop_session() -> void:
	if !session_status:
		return
	
	else:
		config.load(PATH)
		categories = config.get_value("plugin", "categories")
		var _timestamp : String = str("[", Time.get_time_string_from_system(get_value("use_utc")), "] Stopped log session.")
		
		for i in range(categories.size()):

			# Open file
			var _f = FileAccess.open(categories[i][3], FileAccess.READ)
			if !_f:
				var _err = FileAccess.get_open_error()
				if get_value("error_reporting") != 2:
					if _err != OK: push_warning("GoLogger: Failed to open file ", categories[i][3], " with READ ", get_error(_err))
				push_warning("GoLogger: Stopped session but failed to do so properly. Couldn't open the file.")
				session_status = false
				session_status_changed.emit()
				return
			var _content := _f.get_as_text()
			_f.close()
			var _fw = FileAccess.open(categories[i][3], FileAccess.WRITE)
			if !_fw and get_value("error_reporting") != 2:
				var _err = FileAccess.get_open_error()
				if _err != OK: 
					push_warning("GoLogger: Attempting to stop session by writing to file (", categories[i][3], ") -> Error[", _err, "]")
					return
			var _s := str(_content, str(_timestamp + "Stopped Log Session.") if get_value("timestamp_entries") else "Stopped Log Session.")
			_fw.store_line(_s)
			_fw.close()
			categories[i][2] = ""
			categories[i][3] = ""
			categories[i][5] = 0

		 
	config.set_value("plugin", "categories", categories)
	config.save(PATH)
	session_status = false


func toggle_copy_popup(toggle_on : bool) -> void:
	popup.visible              =  toggle_on
	popup_line_edit.editable   =  toggle_on
	popup_nobtn.disabled       = !toggle_on
	popup_yesbtn.disabled      = !toggle_on
	popup_line_edit.focus_mode =  Control.FOCUS_ALL if toggle_on else Control.FOCUS_NONE
	popup_yesbtn.focus_mode    =  Control.FOCUS_ALL if toggle_on else Control.FOCUS_NONE
	popup_nobtn.focus_mode     =  Control.FOCUS_ALL if toggle_on else Control.FOCUS_NONE
	if session_timer != null and !session_timer.is_stopped(): 
		session_timer.paused   =  toggle_on
	if toggle_on:
		popup_line_edit.grab_focus()
		inaction_timer.start(30)
	else:
		copy_name = ""
		popup_line_edit.text = ""
		popup_line_edit.release_focus()
#endregion

#region Helper functions
func get_header() -> String:
	config.load(PATH)
	match get_value("log_header"):
		0: # Project name and version
			var _p_name = str(ProjectSettings.get_setting("application/config/name"))
			var _version = str(ProjectSettings.get_setting("application/config/version"))
			if _p_name == "": 
				_p_name = "Untitled Project"
			if _version == "":  
				_version = "v0.0"
			return str(_p_name, " v", _version, " ")
		1: # Project name
			var _p_name = str(ProjectSettings.get_setting("application/config/name"))
			if _p_name == "": 
				printerr("GoLogger warning: Undefined project name in 'ProjectSettings/application/config/name'.")
				_p_name = "Untitled Project"
			return str(_p_name, " ")
		2: # Version
			var _version = str(ProjectSettings.get_setting("application/config/version"))
			if _version == "": 
				printerr("GoLogger warning: Undefined project version in 'ProjectSettings/application/config/version'.")
				_version = "v0.0"
			return str(_version, " ")
		3: # None
			return ""
	return ""


func check_filename_conflicts() -> String:
	categories = config.get_value("plugin", "categories")
	var seen_resources : Array[String] = []
	for r in categories:
		if !seen_resources.is_empty():
			if r[0] in seen_resources:
				return r[0] 
			else: seen_resources.append(r[0])
		else: seen_resources.append(r[0])
	return ""


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


func get_file_name(category_name : String) -> String:
	var dict  : Dictionary = Time.get_datetime_dict_from_system(get_value("use_utc"))
	var yy  : String = str(dict["year"]).substr(2, 2) # Removes 20 from 2024
	var mm  : String = str(dict["month"]  if dict["month"]  > 9 else str("0", dict["month"]))
	var dd  : String = str(dict["day"]    if dict["day"]    > 9 else str("0", dict["day"]))
	var hh  : String = str(dict["hour"]   if dict["hour"]   > 9 else str("0", dict["hour"]))
	var mi  : String = str(dict["minute"] if dict["minute"] > 9 else str("0", dict["minute"]))
	var ss  : String = str(dict["second"] if dict["second"] > 9 else str("0", dict["second"]))
	var fin : String 
	fin = str(category_name, "(", yy, "-", mm, "-", dd, "_", hh, "-", mi, "-", ss, ").log") if get_value("dash_separator") else str(category_name, "(", yy, mm, dd, "_", hh,mi, ss, ").log")
	return fin 

## DEPRECATED
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
## Uses [param limit_action] to determine which action should be taken when [param session_timer] timeout occurs.
func _on_session_timer_timeout() -> void: 
	match get_value("limit_method"):
		1: # Session Timer
			if get_value("session_timer_action") == 0: # Stop & Start
				stop_session()
				await get_tree().physics_frame
				start_session()
			else: # Stop only
				stop_session()
				session_timer.stop()
		2: # Both Count limit + Session timer
			if get_value("session_timer_action") == 0: # Stop & Start
				stop_session()
				await get_tree().physics_frame
				start_session()
			else: # Stop only
				stop_session()
				session_timer.stop()
	session_timer_stopped.emit()
	session_timer.wait_time = get_value("session_duration")

## Copy session timer. Counts down since the last [signal text_changed] and chancels the operation upon [signal timeout].
func _on_inaction_timer_timeout() -> void:
	popup_state = false

## [LineEdit] For the Copy Session popup.
func _on_line_edit_text_changed(new_text : String) -> void:
	if inaction_timer != null and !inaction_timer.is_stopped(): 
		inaction_timer.stop()
	inaction_timer.start(30)
	
	if new_text != "":
		popup_yesbtn.disabled = false
		popup_line_edit.set_caret_column(popup_line_edit.text.length())
		if new_text.ends_with(".log") or new_text.ends_with(".txt"):
			copy_name = new_text.substr(0, new_text.length() - 4)
		copy_name = popup_line_edit.text
	else:
		popup_yesbtn.disabled = true

## [LineEdit] For the Copy Session popup.
func _on_line_edit_text_submitted(new_text : String) -> void:
	if new_text != "":
		if new_text.ends_with(".log") or new_text.ends_with(".txt"):
			copy_name = new_text.substr(0, new_text.length() - 4)
		else:
			copy_name = popup_line_edit.text
		complete_copy()

## Copy Session popup.
func _on_no_button_button_up() -> void:
	popup_state = false

## Copy Session popup.
func _on_yes_button_button_up() -> void:
	complete_copy()
#endregion
