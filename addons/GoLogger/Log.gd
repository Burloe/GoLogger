extends Node
class_name Log

## Handles session logic and logging entries into .log files.
##
## For installation, setup and how to use instructions, see the README.md or https://github.com/Burloe/GoLogger

## These paths can be accessed by selecting Project > Open User Data Folder in the top-left.
const GAME_PATH = "user://logs/game_Gologs/" ## Path where .log files are created/stored. Will create the directiry if it doesn't exist
const PLAYER_PATH = "user://logs/player_Gologs/" ## Path where .log files are created/stored. Will create the directiry if it doesn't exist
# Normally located in:
# Windows: %APPDATA%\Godot\app_userdata\[project_name]
# macOS:   ~/Library/Application Support/Godot/app_userdata/[project_name]
# Linux:   ~/.local/share/godot/app_userdata/[project_name]


## Returns the string file name for your log containing the current system date and time.
static func get_file_name(log : String) -> String:
	var _d : Dictionary = Time.get_datetime_dict_from_system(true)
	var _fin : String = str(log, "_", _d["year"], "-", _d["month"], "-", _d["day"], "  ", _d["hour"], ".", _d["minute"], ".", _d["second"], ".log")
	# Resulting string name for the log file "game(2024-09-10_12.52.09).log"
	return _fin


## Returns the log entries of the newest file in the given folder. Used to get .log content in external scripts.
static func get_file_contents(folder_path : String) -> String:
	var dir = DirAccess.open(folder_path)
	if !dir:
		var err = DirAccess.get_open_error()
		if err != OK:
			return str("GoLogger Error: Attempting to open directory (", folder_path, ") to find player.log") if GoLogger.debug_warnings_errors else ""
	else:
		var _files = dir.get_files()
		if _files.size() == 0:
			return str("GoLogger Error: No files found in directory (", folder_path, ").") if GoLogger.debug_warnings_errors else ""
		var _newest_file = folder_path + "/" + _files[_files.size() - 1]
		var _fr = FileAccess.open(_newest_file, FileAccess.READ)
		if _fr == null:
			var _err = FileAccess.get_open_error()
			return str("GoLogger Error: Attempting to read .log file -> Error[", _err, "].") if GoLogger.debug_warnings_errors else ""
		var contents = _fr.get_as_text()
		_fr.close()
		return contents

	return str("GoLogger Error: Unable to retrieve file contents in (", folder_path, ")") if GoLogger.debug_warnings_errors else ""



## Initiates a log session, recording game events in the .log file. [param category] denotes the file where the entry is logged. [param utc] will force the date and time format to UTC[yy,mm,ddThh:mm:ss]. [param space] will use a space to separate date and time instead of a "T".[br][b]Note:[/b][br]    You cannot start one session without stopping the previous. Attempting it will do nothing.
static func start_session(utc : bool = true, space : bool = true) -> void: 
	printerr("start() called  session status = ", GoLogger.session_status, "    gamepath = ", GAME_PATH, "      playerpath = ", PLAYER_PATH)
	# Game logs
	if GAME_PATH != null and GAME_PATH != "":
		if GoLogger.session_status:
			if GoLogger.debug_warnings_errors: push_warning("GoLogger Warning: Attempted to start new Game log session before stopping the previous.")
			return
		else:
			var _dir = DirAccess.open(GAME_PATH)
			if !_dir and GoLogger.debug_warnings_errors:
				var _err = DirAccess.get_open_error()
				if _err != OK:
					printerr("GoLogger Error: Failed to open file directory (", GAME_PATH, ")") 
				printerr("GoLogger Error: Failed to open file directory (", GAME_PATH, ")")
				return 
			else:  
				var _files = _dir.get_files() 
				if _files.size() >= GoLogger.file_cap: # File count exceeds cap. Sort then delete oldest file
					printerr("files pre-sort: ", _files)
					_files.sort() 
					printerr("files post_sort: ", _files)
					var _old_file = _files[0]
					var _del_err = _dir.remove(GAME_PATH + _old_file)
					if _del_err != OK: if GoLogger.debug_warnings_errors: printerr("GoLogger Error: Failed to delete file (", _old_file, ") -> Error[", _del_err,"]") 
				GoLogger.current_game_file = GAME_PATH + get_file_name("game") # Game path is "user://logs/game_Gologs/"
				print("Current GAME file: ", GoLogger.current_game_file)
				var _file = FileAccess.open(GoLogger.current_game_file, FileAccess.WRITE)
				if !_file:
					if GoLogger.debug_warnings_errors: printerr("GoLogger Error: Failed to create log file (", GoLogger.current_game_file, ").")
				else:
					var _s := str( "Game Log Session Started[", Time.get_datetime_string_from_system(utc, space), "]:")
					_file.store_line(_s)
					GoLogger.current_game_char_count = _s.length()
					_file.close() 



	
	# Player logs
	if PLAYER_PATH != null and PLAYER_PATH != "": 
		if GoLogger.session_status:
			if GoLogger.debug_warnings_errors: push_warning("GoLogger Warning: Attempted to start new Player log session before stopping the previous.")
			return
		else:
			var _dir = DirAccess.open(PLAYER_PATH)
			if !_dir and GoLogger.debug_warnings_errors:
				var _err = DirAccess.get_open_error()
				if _err != OK:
					printerr("GoLogger Error: Failed to open file directory (", PLAYER_PATH, ")") 
				printerr("GoLogger Error: Failed to open file directory (", PLAYER_PATH, ")")
				return 
			else:
				var _files = _dir.get_files() 
				if _files.size() >= GoLogger.file_cap: # File count exceeds cap. Sort then delete oldest file
					_files.sort() 
					var _old_file = _files[0]
					var _del_err = _dir.remove(PLAYER_PATH + _old_file)
					if _del_err != OK: if GoLogger.debug_warnings_errors: printerr("GoLogger Error: Failed to delete file (", _old_file, ") -> Error[", _del_err,"]") 
				GoLogger.current_player_file = PLAYER_PATH + get_file_name("player") # Player path is "user://logs/player_Gologs/"
				var _file = FileAccess.open(GoLogger.current_player_file, FileAccess.WRITE)
				if !_file:
					if GoLogger.debug_warnings_errors: printerr("GoLogger Error: Failed to create log file (", GoLogger.current_player_file, ").")
				else:
					var _s := str( "Player Log Session Started[", Time.get_datetime_string_from_system(utc, space), "]:")
					_file.store_line(_s)
					GoLogger.current_player_char_count = _s.length()
					_file.close()
	GoLogger.toggle_session_status.emit(true)


## Stores a log entry into the 'game/ui/player.log' file.[br]
## [param timestamp] is used to specify the type of date and time format you want your entries tagged with.[br]
## [param utc] will convert the time into a unified UTC format as opposed to your or your players local time format.
static func entry(file : int, log_entry : String, include_timestamp : bool = true, utc : bool = true) -> void:
	printerr("entry(", file, ") called")
	var _timestamp : String = str("\t[", Time.get_time_string_from_system(utc), "] ") 
	match file:
		0: # GAME
			if !GoLogger.session_status and !GoLogger.end_session_behavior == 2: # Error check
				if GoLogger.debug_warnings_errors: push_warning("GoLogger Warning: Attempted to log Game Entry without starting a session. Remember to call 'start_session(0)' in any _ready function.")
				return
			var _f = FileAccess.open(GoLogger.current_game_file, FileAccess.READ)
			if !_f and GoLogger.debug_warnings_errors:
				var _err = FileAccess.get_open_error()
				if _err != OK:
						printerr("GoLogger Error: Attempting to log entry by reading file (", GoLogger.current_game_file, ") -> Error[", _err, "].") 
						return
			else:
				var _content := _f.get_as_text()
				_f.close()
				if GoLogger.end_session_condition == 1 or GoLogger.end_session_condition == 3: # Character limit or Character limit + Session timer
					if _content.length() > GoLogger.session_character_limit:
						match GoLogger.end_session_behavior:
							0: # Stop & start session
								stop_session()
								start_session()
							1: stop_session() # Stop session only
							2: _content == "Session character limit exceed. Log was purged of previous content. Continuing session:" # Clear log
				var _fw = FileAccess.open(GoLogger.current_game_file, FileAccess.WRITE)
				if !_f and GoLogger.debug_warnings_errors:
					var _err = FileAccess.get_open_error()
					if _err != OK:
						printerr("GoLogger Error: Attempting to log entry into file (", GoLogger.current_game_file, ") -> Error[", _err, "]")
						return
				var _s := str(_content, _timestamp + log_entry if include_timestamp else "\t" + log_entry)
				_f.store_line(_s) 
				GoLogger.current_game_char_count = _s.length()
				_f.close()
		
		1: # PLAYER
			if !GoLogger.session_status and !GoLogger.end_session_behavior == 2: # Error check
				if GoLogger.debug_warnings_errors: push_warning("GoLogger Warning: Attempted to log Game Entry without starting a session. Remember to call 'start_session(0)' in any _ready function.")
				return
			var _f = FileAccess.open(GoLogger.current_player_file, FileAccess.READ)
			if !_f and GoLogger.debug_warnings_errors:
				var _err = FileAccess.get_open_error()
				if _err != OK:
						printerr("GoLogger Error: Attempting to log entry by reading file (", GoLogger.current_player_file, ") -> Error[", _err, "].") 
						return
			else:
				var _content := _f.get_as_text()
				_f.close()
				if GoLogger.end_session_condition == 1 or GoLogger.end_session_condition == 3: # Character limit or Character limit + Session timer
					if _content.length() > GoLogger.session_character_limit:
						match GoLogger.end_session_behavior:
							0: # Stop & start session
								stop_session()
								start_session()
							1: stop_session() # Stop session only
							2: _content == "Session character limit exceed. Log was purged of previous content. Continuing session:" # Clear log
				var _fw = FileAccess.open(GoLogger.current_player_file, FileAccess.WRITE)
				if !_f and GoLogger.debug_warnings_errors:
					var _err = FileAccess.get_open_error()
					if _err != OK:
						printerr("GoLogger Error: Attempting to log entry into file (", GoLogger.current_player_file, ") -> Error[", _err, "]")
						return
				var _s := str(_content, _timestamp + log_entry if include_timestamp else "\t" + log_entry)
				_f.store_line(_s) 
				GoLogger.current_game_char_count = _s.length()
				_f.close()


## Stops the current session. Preventing further entries to be logged. In order to log again, a new session must be started using [code]start_session()[/code]. Doing so will create a new file to log into.
static func stop_session( utc : bool = true, include_timestamp : bool = true) -> void:
	var _timestamp : String = str("[", Time.get_time_string_from_system(utc), "] Stopped log session.")
	if GoLogger.current_game_file != "":
		if GoLogger.session_status:
			var _f = FileAccess.open(GoLogger.current_game_file, FileAccess.READ)
			if !_f and GoLogger.debug_warnings_errors:
				var _err = FileAccess.get_open_error()
				if _err != OK:
					printerr("GoLogger Error: Attempting to stop session by reading file (", GoLogger.current_game_file, ") -> Error[", _err, "]")
					return
			var _content := _f.get_as_text()
			_f.close()
			var _fw = FileAccess.open(GoLogger.current_game_file, FileAccess.WRITE)
			if !_fw:
				var _err = FileAccess.get_open_error()
				if _err != OK and GoLogger.debug_warnings_errors:
					printerr("GoLogger Error: Attempting to stop session by writing to file (", GoLogger.current_game_file, ") -> Error[", _err, "]")
					return
			var _s := str(_content, _timestamp if include_timestamp else "Stopped log session.")
			_fw.store_line(_s)
			GoLogger.current_game_char_count = _s.length()
			_fw.close()
			GoLogger.current_game_file = ""
	
	if GoLogger.current_player_file != "":
		if GoLogger.session_status:
			var _f = FileAccess.open(GoLogger.current_player_file, FileAccess.READ)
			if !_f:
				var _err = FileAccess.get_open_error()
				if _err != OK and GoLogger.debug_warnings_errors:
					printerr("GoLogger Error: Attempting to stop session by reading file (", GoLogger.current_player_file, ") -> Error[", _err, "]")
					return
			var _content := _f.get_as_text()
			_f.close()
			var _fw = FileAccess.open(GoLogger.current_player_file, FileAccess.WRITE)
			if !_fw and GoLogger.debug_warnings_errors:
				var _err = FileAccess.get_open_error()
				if _err != OK:
					printerr("GoLogger Error: Attempting to stop session by writing to file (", GoLogger.current_player_file, ") -> Error[", _err, "]")
					return
			var _s := str(_content, _timestamp if include_timestamp else "Stopped log session.")
			_fw.store_line(_s)
			GoLogger.current_player_char_count = _s.length()
			_fw.close()
			GoLogger.current_player_file = ""
	GoLogger.toggle_session_status.emit(false)
	GoLogger.session_status_changed.emit()
