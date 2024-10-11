extends Node
class_name Log

## Handles session logic and logging entries into .log files.
##
## For installation, setup and how to use instructions, see the README.md or https://github.com/Burloe/GoLogger

## These paths can be accessed by selecting Project > Open User Data Folder in the top-left.
const GAME_PATH = "user://logs/game_Gologs/" ## Directory path where game.log files are created/stored. Directory is created if it doesn't exist
const PLAYER_PATH = "user://logs/player_Gologs/" ## Directory path where player.log files are created/stored. Directory is created if it doesn't exist
# Normally located in:
# Windows: %APPDATA%\Godot\app_userdata\[project_name]
# macOS:   ~/Library/Application Support/Godot/app_userdata/[project_name]
# Linux:   ~/.local/share/godot/app_userdata/[project_name]



## Initiates a log session, recording game events in the .log file. [param category] denotes the file where the entry is logged. [param utc] will force the date and time format to UTC[yy,mm,ddThh:mm:ss]. [param space] will use a space to separate date and time instead of a "T".[br][b]Note:[/b][br]    You cannot start one session without stopping the previous. Attempting it will do nothing.
static func start_session(utc : bool = false, space : bool = true) -> void: 
	# Game logs
	if GAME_PATH != "":
		#region Error check
		if GAME_PATH == null: 
			if !GoLogger.disable_errors: 
				push_error("GoLogger Error: GAME_PATH is null. Assign a valid directory path.")
			return
		if GoLogger.session_status:
			if !GoLogger.disable_errors: push_warning("GoLogger Warning: Attempted to start new Game log session before stopping the previous.")
			return
		#endregion
		else:
			var _dir : DirAccess
			if !DirAccess.dir_exists_absolute(GAME_PATH):
				DirAccess.make_dir_recursive_absolute(GAME_PATH)
			_dir = DirAccess.open(GAME_PATH)
			if !_dir and !GoLogger.disable_errors:
				var _err = DirAccess.get_open_error()
				if _err != OK and !GoLogger.disable_errors: push_warning("GoLogger ", get_err_string(_err), " (", GAME_PATH, ")") 
				if !GoLogger.disable_errors: push_warning("GoLogger ", get_err_string(_err), " (", GAME_PATH, ")") 
				return
			else:  
				GoLogger.current_game_filepath = GAME_PATH + get_file_name("game") # Resulting in "user://logs/game_Gologs/player(yy-mm-dd_hh-mm-ss).log"
				GoLogger.current_game_file     = get_file_name("game")               # Resulting in "player(yy-mm-dd_hh-mm-ss).log"
				var _file = FileAccess.open(GoLogger.current_game_filepath, FileAccess.WRITE)
				var _files = _dir.get_files()  
				while _files.size() > GoLogger.file_cap:
					_files.sort()
					_dir.remove(_files[0])
					_files.remove_at(0)
					var _err = DirAccess.get_open_error()
					if _err != OK: if !GoLogger.disable_errors: push_warning("GoLogger Error: Failed to remove old log file -> ", get_err_string(_err))
				if !_file:
					if !GoLogger.disable_errors: push_warning("GoLogger Error: Failed to create log file (", GoLogger.current_game_file, ").")
				else:
					var _s := str(GoLogger.header_string, "Game Log Session Started[", Time.get_datetime_string_from_system(utc, space), "]:")
					_file.store_line(_s)
					GoLogger.entry_count_game = 1
					_file.close() 
				
	# Player logs
	if PLAYER_PATH != "": 
		#region Error check
		if PLAYER_PATH == null:
			if !GoLogger.disable_errors: 
				push_error("GoLogger Error: PLAYER_PATH is null. Assign a valid directory path.")
			return
		if GoLogger.session_status:
			if !GoLogger.disable_errors: push_warning("GoLogger Warning: Attempted to start new Player log session before stopping the previous.")
			return
		#endregion
		else:
			var _dir : DirAccess
			if !DirAccess.dir_exists_absolute(PLAYER_PATH):
				DirAccess.make_dir_recursive_absolute(PLAYER_PATH)
			_dir = DirAccess.open(PLAYER_PATH)
			if !_dir and !GoLogger.disable_errors:
				var _err = DirAccess.get_open_error()
				if _err != OK and !GoLogger.disable_errors: push_warning("GoLogger ", get_err_string(_err), " (", PLAYER_PATH, ")") 
				if !GoLogger.disable_errors: push_warning("GoLogger ", get_err_string(_err), " (", PLAYER_PATH, ")") 
				return
			else:  
				GoLogger.current_player_filepath = PLAYER_PATH + get_file_name("player") # Resulting in "user://logs/player_Gologs/player(yy-mm-dd_hh-mm-ss).log"
				GoLogger.current_player_file     = get_file_name("player")               # Resulting in "player(yy-mm-dd_hh-mm-ss).log"
				var _file = FileAccess.open(GoLogger.current_player_filepath, FileAccess.WRITE)
				var _files = _dir.get_files()  
				while _files.size() > GoLogger.file_cap:
					_files.sort()
					_dir.remove(_files[0])
					_files.remove_at(0)
					var _err = DirAccess.get_open_error()
					if _err != OK: if !GoLogger.disable_errors: push_warning("GoLogger Error: Failed to remove old log file -> ", get_err_string(_err))
				if !_file:
					if !GoLogger.disable_errors: push_warning("GoLogger Error: Failed to create log file (", GoLogger.current_player_file, ").")
				else:
					var _s := str(GoLogger.header_string, "Player Log Session Started[", Time.get_datetime_string_from_system(utc, space), "]:")
					_file.store_line(_s)
					GoLogger.entry_count_player = 1
					_file.close() 
	GoLogger.toggle_session_status.emit(true)


## Stores a log entry into the 'game/ui/player.log' file.[br]
## [param timestamp] is used to specify the type of date and time format you want your entries tagged with.[br]
## [param utc] will convert the time into a unified UTC format as opposed to your or your players local time format.
static func entry(log_entry : String, file : int = 0, include_timestamp : bool = true, utc : bool = true) -> void:
	var _timestamp : String = str("\t[", Time.get_time_string_from_system(utc), "] ") 
	match file:
		0: # GAME
			# 1.
			if !GoLogger.session_status: 
				if !GoLogger.disable_errors: push_warning("GoLogger Warning: Attempted to log Game Entry without starting a session.")
				return
			else:
				var _f = FileAccess.open(GoLogger.current_game_filepath, FileAccess.READ)
				if !_f:
					var err = FileAccess.get_open_error()
					if err != OK and !GoLogger.disable_errors: push_warning("GoLogger ", get_err_string(err))
				var _c = _f.get_as_text()
				var lines : Array[String] = []
				while not _f.eof_reached():
					var line = _f.get_line().strip_edges(false, true) 
					if line != "": 
						lines.append(line) 
				_f.close()
				GoLogger.entry_count_game = lines.size()
				if lines.size() >= GoLogger.entry_count_limit:
					lines.remove_at(1) 
				var _fw = FileAccess.open(GoLogger.current_game_filepath, FileAccess.WRITE)
				if !_fw:
					var err = FileAccess.get_open_error()
					if err != OK and !GoLogger.disable_errors: push_warning("GoLogger ", get_err_string(err))
				var _s : String = str("\t" + _timestamp + log_entry)
				if GoLogger.log_manage_method == 0 or GoLogger.log_manage_method == 2:
					lines.append(_s) 
					for line in lines: 
						_fw.store_line(line)
				else: _fw.store_line(str(_c, _s))  
				_fw.close()
		
		1: # PLAYER
			if !GoLogger.session_status: # Error check
				if !GoLogger.disable_errors: push_warning("GoLogger Warning: Log entry attempt failed due to inactive session.")
				return
			else:
				var _f = FileAccess.open(GoLogger.current_player_filepath, FileAccess.READ)
				if !_f:
					var _err = FileAccess.get_open_error()
					if _err != OK and !GoLogger.disable_errors: push_warning("GoLogger ", get_err_string(_err))
				var _c = _f.get_as_text()
				var lines : Array[String] = []
				while not _f.eof_reached():
					var line = _f.get_line().strip_edges(false, true) 
					if line != "": 
						lines.append(line) 
				_f.close()
				GoLogger.entry_count_player = lines.size()
				if lines.size() >= GoLogger.entry_count_limit:
					lines.remove_at(1) 
				var _fw = FileAccess.open(GoLogger.current_player_filepath, FileAccess.WRITE)
				if !_fw:
					var _err = FileAccess.get_open_error()
					if _err != OK and !GoLogger.disable_errors: push_warning("GoLogger ", get_err_string(_err))
				var _s : String = str("\t" + _timestamp + log_entry)
				if GoLogger.log_manage_method == 0 or GoLogger.log_manage_method == 2:
					lines.append(_s) 
					for line in lines: 
						_fw.store_line(line)
				else: _fw.store_line(str(_c, _s))  
				_fw.close()


## Stops the current session. Preventing further entries to be logged. In order to log again, a new session must be started using [code]start_session()[/code]. Doing so will create a new file to log into.
static func stop_session( utc : bool = true, include_timestamp : bool = true) -> void:
	var _timestamp : String = str("[", Time.get_time_string_from_system(utc), "] Stopped log session.")
	if GoLogger.current_game_file != "":
		if GoLogger.session_status:
			var _f = FileAccess.open(GoLogger.current_game_filepath, FileAccess.READ)
			if !_f:
				var _err = FileAccess.get_open_error()
				if _err != OK and !GoLogger.disable_errors: push_warning("GoLogger Error: Attempting to stop session by reading file (", GoLogger.current_game_file, ") -> Error[", _err, "]")
			var _content := _f.get_as_text()
			_f.close()
			var _fw = FileAccess.open(GoLogger.current_game_filepath, FileAccess.WRITE)
			if !_fw:
				var _err = FileAccess.get_open_error()
				if _err != OK and !GoLogger.disable_errors:
					push_warning("GoLogger Error: Attempting to stop session by writing to file (", GoLogger.current_game_file, ") -> Error[", _err, "]")
					return
			var _s := str(_content, _timestamp if include_timestamp else "Stopped log session.")
			_fw.store_line(_s)
			_fw.close()
			GoLogger.current_game_file = ""
	
	if GoLogger.current_player_file != "":
		if GoLogger.session_status:
			var _f = FileAccess.open(GoLogger.current_player_filepath, FileAccess.READ)
			if !_f:
				var _err = FileAccess.get_open_error()
				if _err != OK and !GoLogger.disable_errors:
					push_warning("GoLogger Error: Attempting to stop session by reading file (", GoLogger.current_player_file, ") -> Error[", _err, "]")
					return
			var _content := _f.get_as_text()
			_f.close()
			var _fw = FileAccess.open(GoLogger.current_player_filepath, FileAccess.WRITE)
			if !_fw:
				var _err = FileAccess.get_open_error()
				if _err != OK and !GoLogger.disable_errors:
					push_warning("GoLogger Error: Attempting to stop session by writing to file (", GoLogger.current_player_file, ") -> Error[", _err, "]")
					return
			var _s := str(_content, _timestamp if include_timestamp else "Stopped log session.")
			_fw.store_line(_s)
			_fw.close()
			GoLogger.current_player_file = ""
	GoLogger.toggle_session_status.emit(false)
	GoLogger.session_status_changed.emit()


## Helper function to get an error string for likely [DirAccess] and [FileAccess] errors.
static func get_err_string(error_code : int) -> String:
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
	return "Error[X]: Unspecified error-"

## Helper function that returns the string file name for your log containing the current system date and time.[br]
## WARNING: Change this at your own discretion! Removing the "0" from date/time "09" will cause sorting issues which can result inproper file deletion.
static func get_file_name(filename : String) -> String:
	var dict  : Dictionary = Time.get_datetime_dict_from_system()
	var yy  : String = str(dict["year"]).substr(2, 2) # Removes 20 from 2024
	var mm  : String = str(dict["month"] if dict["month"] > 9 else str("0", dict["month"]))
	var dd  : String = str(dict["day"] if dict["day"] > 9 else str("0", dict["day"]))
	var hh  : String = str(dict["hour"] if dict["hour"] > 9 else str("0", dict["hour"]))
	var mi  : String = str(dict["minute"] if dict["minute"] > 9 else str("0", dict["minute"]))
	var ss  : String = str(dict["second"] if dict["second"] > 9 else str("0", dict["second"]))
	var fin : String = str(filename, "(", yy, "-", mm, "-", dd, "_", hh, "-", mi, "-", ss, ").log")
	# Resulting string name for the log file "game(yy-mm-dd_hh-mm-ss).log"
	return fin 

## Helper function that returns the log entries of the newest file in the given folder. Used to get .log content in external scripts.
static func get_file_contents(folder_path : String) -> String:
	var dir = DirAccess.open(folder_path)
	if !dir:
		var err = DirAccess.get_open_error()
		if err != OK:
			return str("GoLogger Error: Attempting to open directory (", folder_path, ") to find player.log") if !GoLogger.disable_errors else ""
	else:
		var _files = dir.get_files()
		if _files.size() == 0:
			return str("GoLogger Error: No files found in directory (", folder_path, ").") if !GoLogger.disable_errors else ""
		var _newest_file = folder_path + "/" + _files[_files.size() - 1]
		var _fr = FileAccess.open(_newest_file, FileAccess.READ)
		if _fr == null:
			var _err = FileAccess.get_open_error()
			return str("GoLogger Error: Attempting to read .log file -> Error[", _err, "].") if !GoLogger.disable_errors else ""
		var contents = _fr.get_as_text()
		_fr.close()
		return contents
	return str("GoLogger Error: Unable to retrieve file contents in (", folder_path, ")") if !GoLogger.disable_errors else ""
