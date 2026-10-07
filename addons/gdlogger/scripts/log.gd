extends Node


## Autoload containing the entire framework that makes up the framework.
##
## The GDLogger Wiki can be found at [url]https://github.com/Burloe/GDLogger/wiki[/url] with information on how to use the plugin, how it works and more information.
## The GitHub repository [url]https://github.com/Burloe/GDLogger[/url] will always have the latest version of
## GDLogger to download. For installation, setup and how to use instructions, see the README.md or in the Github
## repo.

# TODO:


# BUG:d


signal session_toggled(toggled_on: bool) ## Emitted when a log session is started or stopped.
signal msg_logged(msg: String, category: String) ## Emitted when a log message is logged.

@onready var elements_canvaslayer: CanvasLayer = %GDLoggerElements
@onready var session_timer: Timer = %SessionTimer
@onready var instance_id_label: Label = %InstanceIDLabel
@onready var polling_timer: Timer = %PollingTimer

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

@export var data: GDLData = null
const DATA_PATH: String = "res://addons/gdlogger/data.tres"
# const id_overlay_lbl_sett = preload("")
var gl_hotkeys: GDLShortcut = preload("uid://dyi2aml73k4g8")
var session_categories: Array[GDLCategoryData] = []
var session_default_category: String = ""
var copy_name : String = ""
var session_status: bool = false:
	set(value):
		session_status = value
		session_toggled.emit(session_status)
var instance_id: String = "":
	set(value):
		instance_id = value
		instance_id_label.text = str(value)
var cur_id_align: int = 0
var data_mtime: int = -1



func load_data() -> void:
	if !FileAccess.file_exists(DATA_PATH):
		data = GDLData.new()
		ResourceSaver.save(data, DATA_PATH)
	else:
		data = ResourceLoader.load(DATA_PATH, "", ResourceLoader.CACHE_MODE_IGNORE_DEEP)
	data_mtime = _get_data_mtime()




func _get_data_mtime() -> int:
	if !FileAccess.file_exists(DATA_PATH):
		return -1
	return FileAccess.get_modified_time(DATA_PATH)



func _refresh_data_if_changed() -> bool:
	var new_mtime: int = _get_data_mtime()
	if new_mtime == -1 or new_mtime == data_mtime:
		return false
	load_data()
	return true



func _ready() -> void:
	load_data()

	if data.id_toggle:
		instance_id_label.visible = data.id_startup

	session_timer.timeout.connect(_on_timer_timeout.bind(session_timer))
	polling_timer.timeout.connect(_on_timer_timeout.bind(polling_timer))
	_handle_id_align()
	instance_id = _get_instance_id()

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
							print_rich("[font_size=12][color=fc4674][GDLogger][color=white] Instance ID: <[color=lightblue]", instance_id, "[/color]>")

				else:
					if event.is_pressed():
						instance_id_label.show()
					if event.is_released():
						instance_id_label.hide()
						if data.id_print:
							print_rich("[font_size=12][color=fc4674][GDLogger][color=white] Instance ID: <[color=lightblue]", instance_id, "[/color]>")

		# Test entry logging
		# if event is InputEventKey and event.keycode == KEY_COMMA and event.is_released():
		# 	msg("Test entry ", "general", true)
		# if event is InputEventKey and event.keycode == KEY_PERIOD and event.is_released():
		# 	msg("Test entry without category name.")
		# if event is InputEventKey and event.keycode == KEY_MINUS and event.is_released():
		# 	msg("Test entry in non-existent category.", "non_existant_category(should report error with no assigned default category)")

func log_error(error: int = 0, err_data: Array[String] = []) -> void:
	match error:
		0: return
		1: # start_session() errors
			push_warning("GDLogger: Failed to create log file for session(", err_data[1], "). DirAccess Error - ", err_data[1])
		2:
			push_warning("GDLogger: Failed to create log file for session ", err_data, "")
		3: # msg() errors
			printerr("GDLogger: msg() called without specifying a category name and no default category assigned.")
		4:
			printerr("GDLogger: Failed to log entry into default category <", session_default_category, "> Please assign a new default category, or specify a category when logging entries.")
		5:
			printerr("GDLogger: Category ", err_data, " not found.")
		6:
			push_warning("GDLogger: Log entry failed. FileAccess Error - ", err_data)
		7: # stop_session() errors
			printerr("GDLogger: Failed to stop session properly. No valid file path found for category '", err_data, "'.")
		8:
			push_warning("GDLogger: Failed to stop session properly. FileAccess Error - ", err_data)



func start_session() -> void:
	if session_status:
		return

	if data.limit_method in [LimitMethod.SESSION_TIMER, LimitMethod.BOTH]:
		session_timer.start(data.session_duration)

	session_categories.clear()
	for c in data.categories:
		session_categories.append(c.duplicate() as GDLCategoryData)
	session_default_category = data.default_category
	print(data.default_category, session_default_category)


	for i in session_categories:
		_start_category(i)

	session_status = true
	if session_timer.is_stopped() and data.session_timer_action in [1, 2]:
		if session_timer != null: session_timer.start()



func _start_category(i: GDLCategoryData) -> void:
		var c_name: String = i.category_name
		var f_name: String = _get_file_name(c_name)
		var f_path: String = str(data.base_dir, c_name, "_logs/", f_name)
		i.file_name = f_name
		i.file_path = f_path

		var path: String = str(data.base_dir, c_name, "_logs/")
		if !DirAccess.dir_exists_absolute(path):
			DirAccess.make_dir_recursive_absolute(path)

		var dir: DirAccess = DirAccess.open(path)
		if !dir:
			var _err = DirAccess.get_open_error()
			if _err != OK: log_error(1, [error_string(_err), path])
			return

		var _f = FileAccess.open(f_path, FileAccess.WRITE)
		if !_f:
			log_error(2, [f_path])
			return

		var _log_files: PackedStringArray = []
		for file in dir.get_files():
			if file.begins_with(c_name) and file.ends_with(".log"):
				_log_files.append(file)

		i.file_count = _log_files.size()
		if data.file_cap > 0:
			while _log_files.size() > data.file_cap - 1:
				dir.remove(_log_files[0])
				_log_files.remove_at(0)

		var header: String = _get_header(c_name)
		if header != "":
			_f.store_line(header)
		i.entry_count = 1 if header != "" else 0
		_f.close()



func msg(log_msg : String, category_name: String = "", print_msg: bool = false) -> void:
	if log_msg == "":
		return

	if !session_status:
		return

	var target_category: GDLCategoryData = null

	if category_name == "": # Unspecified category -> Use Default category
		if session_default_category.is_empty(): log_error(3)
		else:
			target_category = _get_session_category(session_default_category)
			if !target_category: log_error(4)
	else:
		target_category = _get_session_category(category_name)
		if !target_category: log_error(5, [category_name])

	if !target_category:
		return

	var overwrite_oldest: bool = false
	if data.limit_method in [LimitMethod.ENTRY_COUNT, LimitMethod.BOTH] \
	and target_category.entry_count >= data.entry_cap:
		match data.entry_count_action:
			EntryCountAction.RESTART:
				stop_session()
				start_session()
				msg(log_msg, target_category.category_name, print_msg)
				return
			EntryCountAction.STOP:
				stop_session()
				return
			EntryCountAction.OVERWRITE_ENTRIES:
				overwrite_oldest = true

	var _fw := FileAccess.open(target_category.file_path, FileAccess.READ_WRITE)
	if !_fw:
		log_error(6, [error_string(FileAccess.get_open_error())])
		return

	if overwrite_oldest:
		var content: String = _drop_oldest_entry(_fw.get_as_text())
		_fw.resize(0)
		_fw.seek(0)
		_fw.store_string(content)
		target_category.entry_count -= 1

	_fw.seek_end()
	var new_entry: String = _get_entry_format(log_msg, target_category.category_name)
	_fw.store_line(new_entry)
	_fw.close()
	target_category.entry_count += 1

	msg_logged.emit(target_category.category_name, new_entry)
	if print_msg:
		print_rich("[color=fc4674][font_size=12][GDLogger][color=white] <", target_category.category_name, "> ", new_entry.dedent())



func stop_session() -> void:
	if !session_status:
		return

	var _timestamp : String = str("[", Time.get_time_string_from_system(data.utc), "] Stopped log session.")

	for category in session_categories:
		if category.file_path == "":
			session_status = false
			log_error(7, [category.category_name])
			continue


		var _f = FileAccess.open(category.file_path, FileAccess.READ)
		if !_f:
			var _err = FileAccess.get_open_error()
			log_error(8, [error_string(_err)])
			session_status = false
			return
		var _content := _f.get_as_text()
		_f.close()


		var _fw = FileAccess.open(category.file_path, FileAccess.WRITE)
		if !_fw:
			var _err = FileAccess.get_open_error()
			if _err != OK:
				log_error(8, [error_string(_err)])
				return
		var _s := str(_content, str(_timestamp))
		_fw.store_line(_s)
		_fw.close()

		category.file_name = ""
		category.file_path = ""
		category.entry_count = 0
	
	session_categories.clear()
	session_status = false



func _get_session_category(c_name: String) -> GDLCategoryData:
	for c in session_categories:
		if c.category_name == c_name:
				return c
	return null



func _drop_oldest_entry(content: String) -> String:
	var header_end: int = content.find("\n")
	var first_end: int = content.find("\n", header_end + 1)
	if header_end == -1 or first_end == -1:
		return content
	return content.substr(0, header_end + 1) + content.substr(first_end + 1)




func _get_header(category_name: String = "") -> String:
	# load_data()
	var format: String = data.header_format
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
		var dict  : Dictionary = Time.get_datetime_dict_from_system(data.utc)
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

	var dt: Dictionary = Time.get_datetime_dict_from_system(data.utc)

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

	var format: String = data.entry_format
	var final_entry: String = format
	for tag in _tags:
		if tag in replacements:
			final_entry = final_entry.replace(tag, replacements[tag])
	return final_entry



func _get_file_name(category_name : String) -> String:
	var dict  : Dictionary = Time.get_datetime_dict_from_system(data.utc)
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



func _handle_id_align() -> void: #NOTWORKING
	var id_alignment = data.id_align
	if id_alignment in [0,4,8]:
		instance_id_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT

	elif id_alignment in [1,5,9]:
		instance_id_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER

	elif id_alignment in [2,6,10]:
		instance_id_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT

	if id_alignment in [0,1,2]:
		instance_id_label.vertical_alignment = VERTICAL_ALIGNMENT_TOP

	elif id_alignment in [4,5,6]:
		instance_id_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER

	elif id_alignment in [8,9,10]:
		instance_id_label.vertical_alignment = VERTICAL_ALIGNMENT_BOTTOM

	# print(instance_id_label.horizontal_alignment, " - ", instance_id_label.vertical_alignment)



func _on_timer_timeout(_timer: Timer) -> void:
	match _timer:
		session_timer:
			var _wt: float = data.session_duration
			match data.limit_method:
				LimitMethod.SESSION_TIMER:
					if data.session_timer_action == SessionTimerAction.RESTART:
						stop_session()
						await get_tree().physics_frame
						session_timer.wait_time = _wt
						start_session()
					else: # Stop only
						stop_session()
						session_timer.stop()
				LimitMethod.BOTH:
					if data.session_timer_action == SessionTimerAction.RESTART:
						stop_session()
						await get_tree().physics_frame
						session_timer.wait_time = _wt
						start_session()
					else: # Stop only
						stop_session()
						session_timer.stop()
		polling_timer:
			_refresh_data_if_changed()
			if cur_id_align != data.id_align:
				_handle_id_align()
				cur_id_align = data.id_align
				prints("cur:", cur_id_align, "data:", data.id_align)
