extends Node


## Autoload containing the entire framework that makes up the framework.
##
## The GoLogger Wiki can be found at [url]https://github.com/Burloe/GoLogger/wiki[/url] with information on how to use the plugin, how it works and more information.
## The GitHub repository [url]https://github.com/Burloe/GoLogger[/url] will always have the latest version of
## GoLogger to download. For installation, setup and how to use instructions, see the README.md or in the Github
## repo.

#TODO:


#BUG:


signal session_toggled(toggled_on: bool) ## Emitted when a log session is started or stopped.
signal msg_logged(msg: String, category: String) ## Emitted when a log message is logged.

@onready var elements_canvaslayer: CanvasLayer = %GoLoggerElements
@onready var session_timer: Timer = %SessionTimer
@onready var instance_id_label: Label = %InstanceIDLabel

enum LimitMethod {
	ENTRY_COUNT,
	SESSION_TIMER,
	BOTH,
	SEPERATOR,
	NONE
}

enum EntryCountAction {
	OVERWRITE_ENTRIES,
	RESTART,
	STOP
}

enum SessionTimerAction {
	RESTART,
	STOP
}

enum ErrorReportLevel {
	WARNINGS_ERRORS,
	ERRORS,
	NONE
}

enum ErrorCodes { #NYI - For future use in error/warning messages - On hold
		ERR_NONE,
		ERR_LOAD_CATEGORIES_FAILED,
		ERR_SAVE_CATEGORIES_FAILED,
		ERR_SESSION_ACTIVE,
		ERR_NO_CATEGORIES,
		ERR_INVALID_CATEGORY,
		ERR_INVALID_ENTRY,
		ERR_INVALID_FILE_PATH,
		ERR_SESSION_INACTIVE,
		ERR_SETTINGS_FILE_CREATION_FAIL,
		ERR_FILE_ACCESS,
		ERR_DIR_ACCESS
}

@export var data: GLData = null
var data_path: String = "res://addons/gologger/data.tres"
var gl_hotkeys: GLShortcut = preload("uid://dyi2aml73k4g8")
var copy_name : String = ""
var session_status: bool = false:
	set(value):
		session_status = value
		session_toggled.emit(session_status)
var instance_id: String = "":
	set(value):
		instance_id = value 
		instance_id_label.text = str("  ", value, "  ")

var cat_data : Dictionary = {
	"game": {
		"category_name": "game",
		"file_name": "game(251113_161313).log",
		"file_path": "user://GoLogger/game_logs/game(251113_161313).log",
		"file_count": 0,
		"entry_count": 0,
		"is_locked": false
	}
}


func load_data() -> void:
	if !FileAccess.file_exists(data_path):
		data = GLData.new()
		var err := ResourceSaver.save(data, data_path)
		if err == OK and data.error_reporting != 2:
			print("GoLogger: No data found. Loading default.")
		else:
			push_error("GoLogger Error: No data found and unable to restore to defaults. Try to manually create a new GLData resource at '", data_path, "'.")
	else:
		data = load(data_path)




func _ready() -> void:
	load_data()
 
	if data.id_toggle:
		instance_id_label.visible = data.id_startup

	session_timer.timeout.connect(_on_timer_timeout.bind(session_timer))

	assert(_check_category_name_conflicts().is_empty(), str("GoLogger: Conflicting category name(s) found: ", _check_category_name_conflicts()))

	var id_alignment = data.id_align
	if id_alignment in [0,4,8]:
		instance_id_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT

	if id_alignment in [1,5,9]:
		instance_id_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER

	if id_alignment in [2,6,10]:
		instance_id_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT

	if id_alignment in [0,1,2]:
		instance_id_label.vertical_alignment = VERTICAL_ALIGNMENT_TOP

	if id_alignment in [4,5,6]:
		instance_id_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER

	if id_alignment in [7,8,9]:
		instance_id_label.vertical_alignment = VERTICAL_ALIGNMENT_BOTTOM


	instance_id = _get_instance_id()

	validate_settings()
	load_category_data()

	if data.autostart:
		start_session()



func _input(event: InputEvent) -> void:
	if !Engine.is_editor_hint():
		if event is InputEventKey\
		or event is InputEventJoypadButton\
		or event is InputEventJoypadMotion and event.axis == 4\
		or event is InputEventJoypadMotion and event.axis == 5: # Only allow trigger axes
			if gl_hotkeys.start_session_hotkey.shortcut.matches_event(event) and event.is_released():
				start_session()
			if gl_hotkeys.stop_session_hotkey.shortcut.matches_event(event) and event.is_released():
				stop_session()

			if gl_hotkeys.display_instance_id_hotkey.shortcut.matches_event(event):
				if data.id_toggle:
					if event.is_released():
						instance_id_label.hide() if instance_id_label.visible else instance_id_label.show()
						if data.id_print:
							print_rich("[font_size=12][color=fc4674][GoLogger][color=white] Instance ID: <[color=lightblue]", instance_id, "[/color]>")

				else:
					if event.is_pressed():
						instance_id_label.show()
					if event.is_released():
						instance_id_label.hide()
						if data.id_print:
							print_rich("[font_size=12][color=fc4674][GoLogger][color=white] Instance ID: <[color=lightblue]", instance_id, "[/color]>")

		# Test entry logging
		# if event is InputEventKey and event.keycode == KEY_COMMA and event.is_released():
		# 	msg("Test entry ", "game", true)
		# if event is InputEventKey and event.keycode == KEY_PERIOD and event.is_released():
		# 	msg("Test entry without category name.")
		# if event is InputEventKey and event.keycode == KEY_MINUS and event.is_released():
		# 	msg("Test entry in non-existent category.", "non_existant_category(should report error with no assigned default category)")



func start_session() -> void:
	if session_status: # ErrCheck -> Session already started
		if data.error_reporting != 2:
			push_warning("GoLogger: Failed to start session, a session is already active.")
		return

	if data.limit_method == LimitMethod.SESSION_TIMER or data.limit_method == LimitMethod.BOTH:
		session_timer.start(data.session_duration)

	# for i in range(cat_data["categories"]["category_names"].size()):
	for i in data.categories:
		var c_name: String = i.category_name
		var f_name: String = _get_file_name(c_name) # game(date-time).log
		var f_path: String = str(data.base_dir, c_name, "_logs/", f_name)

		i.file_name = f_name
		i.file_path = f_path

		# Open/create directory
		var path: String = str(data.base_dir, c_name, "_logs/")
		var dir : DirAccess
		if !DirAccess.dir_exists_absolute(path):
			DirAccess.make_dir_recursive_absolute(path)

		dir = DirAccess.open(path)

		if !dir and data.error_reporting != 2: # ErrCheck
			var _err = DirAccess.get_open_error()
			if _err != OK: push_warning("GoLogger: ", get_error(_err, "DirAccess"), " (", path, ").")
			continue

		var _f = FileAccess.open(f_path, FileAccess.WRITE)
		if !_f and data.error_reporting != 2:
			push_warning("GoLogger: Failed to create log file for session(", f_path, ").")
			continue

		var _file_list = dir.get_files()
		var _log_files: PackedStringArray = []

		for file in _file_list:
			if file.begins_with(c_name) and file.ends_with(".log"):
				_log_files.append(file)

		cat_data[c_name]["file_count"] = _log_files.size()
		print(_log_files)
		if data.file_cap > 0:
			while _log_files.size() > data.file_cap -1:
				# _log_files.sort()
				dir.remove(_log_files[0])
				_log_files.remove_at(0)

				var _err = DirAccess.get_open_error() # Checks for errors during dir.remove()
				if _err != OK and data.error_reporting != 2:
					push_warning("GoLogger Error: Failed to remove old log file -> ", get_error(_err, "DirAccess"))

		var header: String = _get_header(c_name)
		if header != "":
			_f.store_line(header)
		_f.close()

	session_status = true
	if session_timer.is_stopped() and data.session_timer_action in [1, 2]:
		if session_timer != null: session_timer.start()


func msg(log_msg : String, category_name: String = "", print_msg: bool = false) -> void:
	var target_category: String = category_name
	var target_filepath: String = data.get_category(target_category).file_path

	# var data: Dictionary = {
	# 	"target_category": 			category_name,
	# 	"category_names": 			_get_config_value("categories", "category_names"),
	# 	"default_category":	 		_get_config_value("categories", "default_category"),
	# 	"target_filepath": 			_get_config_value(str("categories." + category_name), "file_path", "Failed to get file path!"),
	# 	"limit_method": 				_get_config_value("settings", "limit_method"),
	# 	"entry_action": 				_get_config_value("settings", "entry_count_action"),
	# 	"entry_cap": 						_get_config_value("settings", "entry_cap"),
	# 	"session_timer_action": _get_config_value("settings", "session_timer_action"),
	# 	"session_duration": 		_get_config_value("settings", "session_duration"),
	# 	"err_lv": 							_get_config_value("settings", "error_reporting"),
	# } 
	print(data)

	if log_msg == "":
		if data.error_reporting != 2:
			printerr("GoLogger: Attempted to log empty entry.")
		return

	if target_category: # Unspecified category -> Use Default category
		if data.default_category != "" and data.get_category_names().has(data.default_category):
			target_category = data.default_category
			target_filepath = data.get_category(target_category).file_path

		else:
			if data.error_reporting != 2:
				if data.default_category.is_empty():
					printerr("GoLogger: msg() called without specifying a category name and no default category assigned.\n\t Entry:\n", log_msg)
				else:
					if !data.get_category_names().has(data.default_category):
						printerr("GoLogger: Entry failed to log into default category[", data.default_category, "] assigned does not exist(the default category was likely deleted). Please assign a new default category, or specify a category when logging entries.")
					printerr("GoLogger: Attempted to log entry into a default category[", data.default_category,"] that doesn't exist.")

			return

	if target_category.is_empty():
		if data.error_reporting != 2:
			printerr("GoLogger: Attempted to log entry without categories.")
		return

	if target_category not in data.get_category_names():
		if data.error_reporting != 2:
			printerr("GoLogger: Category '" + data["target_category"] + "' not found. Check correct spelling.")
		return

	if !session_status:
		return

	if target_filepath == "" or !target_filepath:
		if data.error_reporting != 2:
			printerr("GoLogger: No valid file path found for category '" + target_category + "[" + instance_id + "]'.")
		return


	# Read existing Entries (note that first entry is Log Header)
	var _f = FileAccess.open(target_filepath, FileAccess.READ)
	if !_f: # ER
		var _err = FileAccess.get_open_error()
		if _err != OK and data.error_reporting != 2:
			push_warning("Gologger Error: Log entry failed [", get_error(_err, "FileAccess"), ".")
		return

	var lines : Array[String] = []
	while not _f.eof_reached():
		var _l = _f.get_line().strip_edges(false, true)
		if _l != "":
			lines.append(_l)
	_f.close()
	config.load(PATH)
	config.set_value("categories." + target_category, "entry_count", lines.size())
	config.save(PATH)

	# Handle Limit Methods
	match data["limit_method"]:

		LimitMethod.ENTRY_COUNT:
			match data["entry_action"]:
				EntryCountAction.OVERWRITE_ENTRIES:
					while lines.size() >= data["entry_cap"]:
						lines.remove_at(1) # Retain header

				EntryCountAction.RESTART:
					if lines.size() >= data["entry_cap"]:
						stop_session()
						start_session()
						msg(log_msg, data["target_category"])
						return

				EntryCountAction.STOP:
					if lines.size() >= data["entry_cap"]:
						stop_session()
						return

		LimitMethod.SESSION_TIMER:
			match data["session_timer_action"]:
				SessionTimerAction.RESTART:
					stop_session()
					start_session()
					msg(log_msg, data["target_category"])
					return

				SessionTimerAction.STOP:
					stop_session()
					return

		LimitMethod.BOTH:
			match data["entry_action"]:
				EntryCountAction.RESTART:
					if lines.size() >= data["entry_cap"]:
						stop_session()
						start_session()
						msg(log_msg, data["target_category"])
						return

				EntryCountAction.STOP:
					if lines.size() >= data["entry_cap"]:
						stop_session()
						return

	# Rewrite file with existing lines / Update entry count
	cat_data[data["target_category"]]["entry_count"] = lines.size()
	var _fw = FileAccess.open(data["target_filepath"], FileAccess.WRITE)
	if !_fw: # ErrCheck
		var err = FileAccess.get_open_error()
		if err != OK and data.error_reporting != 2:
			push_warning("GoLogger error: Log entry failed. ", get_error(err, "FileAccess"), "")

	for line in lines:
		_fw.store_line(str(line))

	# Write new entry
	var new_entry: String = _get_entry_format(log_msg, data["target_category"])
	_fw.store_line(new_entry)
	_fw.close()
	msg_logged.emit(data["target_category"], new_entry)
	if print_msg:
		print_rich("[color=fc4674][font_size=12][GoLogger][color=white] <", data["target_category"], "> ", new_entry.dedent())



func stop_session() -> void:
	if !session_status:	return

	load_category_data()

	var _err_lv: int = _get_config_value("settings", "error_reporting")
	var _timestamp : String = str("[", Time.get_time_string_from_system(_get_config_value("settings", "use_utc")), "] Stopped log session.")

	for category in config.get_value("categories", "category_names", []):
		var _fp = cat_data[category]["file_path"]
		if _fp == "":
			if _err_lv != 2:
				push_warning("GoLogger: Failed to stop session properly. No valid file path found for category '", category, "'.")
			continue


		var _f = FileAccess.open(_fp, FileAccess.READ)
		if !_f:
			var _err = FileAccess.get_open_error()
			if _err_lv != 2:
				if _err != OK: push_warning("GoLogger: Failed to open file ", _fp, " with READ ", get_error(_err))
			push_warning("GoLogger: Failed to stop session properly. Error opening file!", _fp)
			session_status = false
			return
		var _content := _f.get_as_text()
		_f.close()


		var _fw = FileAccess.open(_fp, FileAccess.WRITE)
		if !_fw and _err_lv != 2:
			var _err = FileAccess.get_open_error()
			if _err != OK:
				push_warning("GoLogger: Attempting to stop session by writing to file (", _fp, ") -> Error[", _err, "]")
				return
		var _s := str(_content, str(_timestamp))
		_fw.store_line(_s)
		_fw.close()

		config.set_value("categories." + str(category), "file_name", "")
		config.set_value("categories." + str(category), "file_path", "")
		config.set_value("categories." + str(category), "entry_count", 0)

	config.save(PATH)
	session_status = false



func create_settings_file() -> void: # Mirror
	var cf := ConfigFile.new()

	for key in settings_dict.keys():
		for field in ["section", "default", "type", "control"]:
			if field == "control" and settings_dict[key]["section"] == "categories":
				continue

			if not settings_dict[key].has(field):
				push_error("GoLogger: Error creating a settings file. 'settings_dict' entry '%s' missing '", field, "' field", % key)
				continue

		var section = settings_dict[key].get("section", "settings")
		cf.set_value(section, key, settings_dict[key]["default"])

	var _s = cf.save(PATH)
	if _s != OK:
		var _e = cf.get_open_error()
		printerr(str("GoLogger error: Failed to create settings.ini file! ", get_error(_e, "ConfigFile")))
		return

	config.load(PATH) 



func validate_settings() -> void: # Mirror
	config.load(PATH) 

	for key in settings_dict.keys():
		var setting: Dictionary = settings_dict.get(key, {})
		var a_fields = ["section", "name", "type", "control", "default"]
		var b_fields = ["section", "name", "type", "default"]

		# Check missing fields
		if setting.has("section"):
			var fs = a_fields.duplicate()

			if setting["section"] == "categories":
				fs = b_fields.duplicate()

			# Collect + report missing fields
			if !setting.has_all(fs):
				var _e: Array[String] = []
				for field in fs:
					if !setting.has(field):
						_e.append(field)

				if not _e.is_empty():
					push_warning(str("GoLogger error: invalid settings_dict key. Missing field(s) ", _e, " for setting <", key, ">"))

		# Validate Presence
		if !config.has_section(setting["section"]) or !config.has_section_key(setting["section"], setting["name"]):
			config.set_value(setting["section"], setting["name"], setting["default"])
			continue

		# Validate Type
		if typeof(config.get_value(setting["section"], setting["name"])) != setting["type"]:
			config.set_value(setting["section"], setting["name"], setting["default"])

	config.save(PATH)



static func get_error(error : int, object_type : String = "") -> String:
	match error:
		1:  return str("<Error[1] ",  object_type, " Failed>")
		2:  return str("<Error[2] ",  object_type, " Unavailable>")
		3:  return str("<Error[3] ",  object_type, " Unconfigured>")
		4:  return str("<Error[4] ",  object_type, " Unauthorized>")
		5:  return str("<Error[5] ",  object_type, " Parameter range>")
		6:  return str("<Error[6] ",  object_type, " Out of memory>")
		7:  return str("<Error[7] ",  object_type, " File: Not found>")
		8:  return str("<Error[8] ",  object_type, " File: Bad drive>")
		9:  return str("<Error[9] ",  object_type, " File: Bad File path>")
		10: return str("<Error[10] ", object_type, " No File permission>")
		11: return str("<Error[11] ", object_type, " File already in use>")
		12: return str("<Error[12] ", object_type, " Can't open File>")
		13: return str("<Error[13] ", object_type, " Can't write to File>")
		14: return str("<Error[14] ", object_type, " Can't read to File>")
		15: return str("<Error[15] ", object_type, " File unrecognized>")
		16: return str("<Error[16] ", object_type, " File corrupt>")
		17: return str("<Error[17] ", object_type, " File missing dependencies>")
		18: return str("<Error[18] ", object_type, " End of File>")
		19: return str("<Error[19] ", object_type, " Can't open>")
		20: return str("<Error[20] ", object_type, " Can't create>")
		21: return str("<Error[21] ", object_type, " Query failed>")
		22: return str("<Error[22] ", object_type, " Already in use>")
		23: return str("<Error[23] ", object_type, " Locked>")
		24: return str("<Error[24] ", object_type, " Timeout>")
		25: return str("<Error[25] ", object_type, " Can't connect>")
		26: return str("<Error[26] ", object_type, " Can't resolve>")
		27: return str("<Error[27] ", object_type, " Connection error>")
		28: return str("<Error[28] ", object_type, " Can't acquire resource>")
		29: return str("<Error[29] ", object_type, " Can't fork process>")
		30: return str("<Error[30] ", object_type, " Invalid data>")
		31: return str("<Error[31] ", object_type, " Invalid parameter>")
		32: return str("<Error[32] ", object_type, " Already exists>")
		33: return str("<Error[33] ", object_type, " Doesn't exist>")
		34: return str("<Error[34] ", object_type, " Database: Can't read>")
		35: return str("<Error[35] ", object_type, " Database: Can't write>")
		36: return str("<Error[36] ", object_type, " Compilation failed>")
		37: return str("<Error[37] ", object_type, " Method not found>")
		38: return str("<Error[38] ", object_type, " Link failed>")
		39: return str("<Error[39] ", object_type, " Script failed>")
		40: return str("<Error[40] ", object_type, " Cyclic link>")
		41: return str("<Error[41] ", object_type, " Invalid declaration>")
		42: return str("<Error[42] ", object_type, " Duplicate symbol>")
		43: return str("<Error[43] ", object_type, " Parse error>")
		44: return str("<Error[44] ", object_type, " Busy error>")
		46: return str("<Error[45] ", object_type, " Skip error>")
		47: return str("<Error[46] ", object_type, " Help error>")
		48: return str("<Error[47] ", object_type, " Bug error>")
	return "N/A"




func _get_default(key: String, custom_default: Variant = null) -> Variant:
	return settings_dict.get(key, {}).get("default", custom_default)



func _check_category_name_conflicts() -> Array[String]:
	var categories = config.get_value("categories", "category_names" , [])
	if categories.is_empty():
		return []

	var found_conflicts: Array[String] = []
	var seen_names : Array[String] = []

	for name in categories:
		if name in seen_names:
			found_conflicts.append(name)
		else: seen_names.append(name)
	return found_conflicts



func _get_header(category_name: String = "") -> String:
	config.load(PATH)
	var format: String = _get_config_value("settings", "log_header_format")
	var _header: String = ""
	var _tags: Array[String] = [
		"{project_name}",
		"{version}",
		"{category}",
		"{yy}",
		"{mm}",
		"{dd}",
		"{hh}",
		"{mi}",
		"{ss}"
	]

	if format != null and format != "":
		var dict  : Dictionary = Time.get_datetime_dict_from_system(_get_config_value("settings", "use_utc"))
		var yy  : String = str(dict["year"]).substr(2, 2) # Removes 20 from 2024
		var mm  : String = str(dict["month"]  if dict["month"]  > 9 else str("0", dict["month"]))
		var dd  : String = str(dict["day"]    if dict["day"]    > 9 else str("0", dict["day"]))
		var hh  : String = str(dict["hour"]   if dict["hour"]   > 9 else str("0", dict["hour"]))
		var mi  : String = str(dict["minute"] if dict["minute"] > 9 else str("0", dict["minute"]))
		var ss  : String = str(dict["second"] if dict["second"] > 9 else str("0", dict["second"]))

		var replacements: Dictionary = {
			"{project_name}": str(ProjectSettings.get_setting("application/config/name")),
			"{version}": str(ProjectSettings.get_setting("application/config/version")),
			"{category}": category_name,
			"{yy}": yy,
			"{mm}": mm,
			"{dd}": dd,
			"{hh}": hh,
			"{mi}": mi,
			"{ss}": ss
		}

		_header = format
		for tag in _tags:
			if tag in replacements:
				_header = _header.replace(tag, replacements[tag])

		return str(_header, " ")
	return ""



func _get_entry_format(entry: String, category_name: String) -> String:
	var _tags: Array[String] = [
		"{project_name}",
		"{version}",
		"{instance_id}",
		"{category}",
		"{yy}",
		"{mm}",
		"{dd}",
		"{hh}",
		"{mi}",
		"{ss}",
		"{entry}"
	]

	var dt: Dictionary = Time.get_datetime_dict_from_system(_get_config_value("settings", "use_utc", false))

	var yy: String = str(dt["year"]).substr(2, 2)
	var mm: String = str(dt["month"]  if dt["month"]  > 9 else str("0", dt["month"]))
	var dd: String = str(dt["day"]    if dt["day"]    > 9 else str("0", dt["day"]))
	var hh: String = str(dt["hour"]   if dt["hour"]   > 9 else str("0", dt["hour"]))
	var mi: String = str(dt["minute"] if dt["minute"] > 9 else str("0", dt["minute"]))
	var ss: String = str(dt["second"] if dt["second"] > 9 else str("0", dt["second"]))

	var replacements: Dictionary = {
		"{project_name}": str(ProjectSettings.get_setting("application/config/name")),
		"{version}": str(ProjectSettings.get_setting("application/config/version")),
		"{instance_id}": instance_id,
		"{category}": category_name,
		"{yy}": yy,
		"{mm}": mm,
		"{dd}": dd,
		"{hh}": hh,
		"{mi}": mi,
		"{ss}": ss,
		"{entry}": entry
	}

	var format: String = _get_config_value("settings", "entry_format", settings_dict.get("entry_format", {}).get("default"))
	var final_entry: String = format
	for tag in _tags:
		if tag in replacements:
			final_entry = final_entry.replace(tag, replacements[tag])
	return final_entry



func _get_file_name(category_name : String) -> String:
	var dict  : Dictionary = Time.get_datetime_dict_from_system(_get_config_value("settings", "use_utc"))
	var yy  : String = str(dict["year"]).substr(2, 2) # Removes 20 from 2024
	var mm  : String = str(dict["month"]  if dict["month"]  > 9 else str("0", dict["month"]))
	var dd  : String = str(dict["day"]    if dict["day"]    > 9 else str("0", dict["day"]))
	var hh  : String = str(dict["hour"]   if dict["hour"]   > 9 else str("0", dict["hour"]))
	var mi  : String = str(dict["minute"] if dict["minute"] > 9 else str("0", dict["minute"]))
	var ss  : String = str(dict["second"] if dict["second"] > 9 else str("0", dict["second"]))
	var fin : String
	fin = str(category_name, "(", yy, mm, dd, "_", hh,mi, ss, ").log")
	return fin


func _get_instance_id() -> String:
	var rng := RandomNumberGenerator.new()
	var letters: String = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz"
	var id_len: int = 5
	var id_str: String = ""
	rng.randomize()
	for i in range(id_len):
		var idx: int = rng.randi_range(0, letters.length() - 1)
		id_str += letters[idx]
	return id_str




func _on_timer_timeout(_timer: Timer) -> void:
	match _timer:
		session_timer:
			var _wt: float = _get_config_value("settings", "session_duration")
			match _get_config_value("settings", "limit_method"):
				LimitMethod.SESSION_TIMER: # Session Timer
					if _get_config_value("settings", "session_timer_action") == 0: # Stop & Start
						stop_session()
						await get_tree().physics_frame
						session_timer.wait_time = _wt
						start_session()
					else: # Stop only
						stop_session()
						session_timer.stop()
				LimitMethod.BOTH: # Both Count limit + Session timer
					if _get_config_value("settings", "session_timer_action") == 0: # Stop & Start
						stop_session()
						await get_tree().physics_frame
						session_timer.wait_time = _wt
						start_session()
					else: # Stop only
						stop_session()
						session_timer.stop()
