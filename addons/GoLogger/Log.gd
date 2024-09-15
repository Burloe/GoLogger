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
	var _fin : String = str(log, "_", _d["year"], "-", _d["month"], "-", _d["day"], "_", _d["hour"], ".", _d["minute"], ".", _d["second"], ".log")
	# Resulting string name for the log file "game(2024-09-10_12.52.09).log"
	return _fin


## Returns the log entries of the newest file in the given folder. Used to get .log content in external scripts.
static func get_file_contents(folder_path : String) -> String:
	var dir = DirAccess.open(folder_path) 
	if !dir:
		var err = DirAccess.get_open_error()
		if err != OK:
			return str("GoLogger Error: Attempting to open directory (", GAME_PATH, ") to find player.log") if GoLogger.debug_warnings_errors else ""
	else:
		var _files = dir.get_files()
		#print(folder_path + _files[_files.size() -1])
		var _newest_file = str(folder_path + _files[_files.size() -1])
		var _fr = FileAccess.open(_newest_file, FileAccess.READ)
		if !_fr:
			var _err = FileAccess.get_open_error() 
			if _err != OK: 
				return str("GoLogger Error: Reading player.log file -> Error[", _err, "].") if GoLogger.debug_warnings_errors else ""
		return _fr.get_as_text() # Successful retrieval 
	return str("GoLogger Error: Unable to retrieve file contents in (", folder_path, ")") if GoLogger.debug_warnings_errors else ""




## Initiates a log session, recording game events in the .log file. [param category] denotes the file where the entry is logged. [param utc] will force the date and time format to UTC[yy,mm,ddThh:mm:ss]. [param space] will use a space to separate date and time instead of a "T".[br][b]Note:[/b][br]    You cannot start one session without stopping the previous. Attempting it will do nothing.
static func start_session(utc : bool = true, space : bool = true) -> void: 
	#printerr("start(", file, ") called")
	# Game logs
	if GAME_PATH != null or GAME_PATH != "":
		if GoLogger.session_status:
			if GoLogger.debug_warnings_errors: push_warning("GoLogger Warning: Attempted to start new Game log session before stopping the previous.")
			return
		else:
			var _dir = DirAccess.open(GAME_PATH)
			if !_dir:
				if GoLogger.debug_warnings_errors: printerr("GoLogger Error: Unable to open file directory (", GAME_PATH, ")") 
				var _error = DirAccess.make_dir_absolute(GAME_PATH)
				if _error != OK:
					if GoLogger.debug_warnings_errors: printerr("GoLogger Error: Failed to create directory (", GAME_PATH, ") -> Error[", _error,"]")
			else:  
				var _files = _dir.get_files() 
				if _files.size() >= GoLogger.file_cap:
					_files.sort() 
					var _old_file = _files[0]
					var _delete_err = _dir.remove(GAME_PATH + _old_file)
					if _delete_err != OK:
						printerr("GoLogger Error: Failed to delete file (", _old_file, ") -> Error[", _delete_err,"]") 
				var _log_filepath = GAME_PATH + get_file_name("game")
				var _file = FileAccess.open(_log_filepath, FileAccess.WRITE)
				if _file:
					var _s := str( "Game Log Session Started[", Time.get_datetime_string_from_system(utc, space), "]:")
					_file.store_line(str( "Game Log Session Started[", Time.get_datetime_string_from_system(utc, space), "]:"))
					GoLogger.current_game_char_count = _s.length()
					_file.close()
					GoLogger.toggle_session_status.emit(true)
				else:
					if GoLogger.debug_warnings_errors: printerr("GoLogger Error: Failed to create log file (", _log_filepath, ").")
	# Player logs
	elif PLAYER_PATH != null or PLAYER_PATH != "":
		if GoLogger.session_status:
			if GoLogger.debug_warnings_errors: push_warning("GoLogger Warning: Attempted to start new Player log session before stopping the previous.")
			return
		else:
			var _dir = DirAccess.open(PLAYER_PATH)
			if !_dir: 
				printerr("GoLogger Error: Unable to open file directory (", PLAYER_PATH, ")") 
				var _error = DirAccess.make_dir_absolute(PLAYER_PATH) 
				if _error != OK: if GoLogger.debug_warnings_errors: push_error("GoLogger Error: Failed to create directory (", PLAYER_PATH, ") -> Error[", _error,"]")
			else:
				var _files = _dir.get_files() 
				if _files.size() >= GoLogger.file_cap:
					_files.sort() 
					var _old_file = _files[0]
					var _delete_err = _dir.remove(PLAYER_PATH + _old_file)
					if _delete_err != OK: if GoLogger.debug_warnings_errors: printerr("GoLogger Error: Failed to delete file (", _old_file, ") -> Error[", _delete_err,"]") 
				var _log_filepath = PLAYER_PATH + get_file_name("player")
				var _file = FileAccess.open(_log_filepath, FileAccess.WRITE)
				if _file:
					var _s := str( "Player Log Session Started[", Time.get_datetime_string_from_system(utc, space), "]:")
					_file.store_line(_s)
					GoLogger.current_player_char_count = _s.length()
					_file.close()
					GoLogger.toggle_session_status.emit(true)
				else:
					if GoLogger.debug_warnings_errors: printerr("GoLogger Error: Failed to create log file (", _log_filepath, ").")


## Stores a log entry into the 'game/ui/player.log' file.[br]
## [param timestamp] is used to specify the type of date and time format you want your entries tagged with.[br]
## [param utc] will convert the time into a unified UTC format as opposed to your or your players local time format.
static func entry(file : int, log_entry : String, include_timestamp : bool = true, utc : bool = true) -> void:
	printerr("entry(", file, ") called")
	match file:
		0: # Game Log
			if !GoLogger.session_status and !GoLogger.end_session_behavior == 2:
				if GoLogger.debug_warnings_errors: push_warning("GoLogger Warning: Attempted to log Game entry without starting a session. Remember to call 'start_session(0)' in a _ready() function.")
				return
				
			var _dir = DirAccess.open(GAME_PATH) 
			if !_dir:
				var _err = DirAccess.get_open_error()
				if _err != OK:
					if GoLogger.debug_warnings_errors: printerr("GoLogger Error: Attempting to open directory (", GAME_PATH, ") to find game.log -> Error[", _err, "]")
					return
			
			else: 
				var _files = _dir.get_files()
				var _newest_file = str(GAME_PATH + _files[_files.size() -1]) 
				var _fr = FileAccess.open(_newest_file, FileAccess.READ)# Open last newest file with READ
				if !_fr:
					var _err = FileAccess.get_open_error() 
					if _err != OK: 
						if GoLogger.debug_warnings_errors: if GoLogger.debug_warnings_errors: printerr("GoLogger Error: Reading game.log file -> Error[", _err, "].") 
						return
				
				var _content = _fr.get_as_text() # Store old log entries before the file is truncated
				_fr.close()
				if GoLogger.end_session_condition == 1 or GoLogger.end_session_condition == 3:
					if _content.length() > GoLogger.session_character_limit:
						match GoLogger.end_session_behavior:
							0:
								stop_session(0)
								start_session(0)
							1: stop_session(0)
							2: _content = ""

				var _f = FileAccess.open(_newest_file, FileAccess.WRITE) 
				if !_f: 
					var _ferr = FileAccess.get_open_error()  
					if _ferr != OK: 
						if GoLogger.debug_warnings_errors: printerr("GoLogger Error: Writing to game.log file -> Error[", _ferr, "].")
						return
				
				var _timestamp : String = str("\t[", Time.get_time_string_from_system(utc), "] ") 
				# Re-enter old log entries then add the new entry, prefixed with timestamp if include_timestamp allows
				var _s := str(_content, _timestamp + log_entry if include_timestamp else "\t" + log_entry)
				_f.store_line(_s) 
				GoLogger.current_game_char_count = _s.length()
				_f.close()
				
		1: # Player Log
			if !GoLogger.session_status and !GoLogger.end_session_behavior == 2:
				if GoLogger.debug_warnings_errors: push_warning("GoLogger Warning: Attempted to log Player entry without starting a session. Remember to call 'start_session(0)' in a _ready() function.")
				return
				
			var _dir = DirAccess.open(PLAYER_PATH) 
			if !_dir:
				var _err = DirAccess.get_open_error()
				if _err != OK:
					if GoLogger.debug_warnings_errors: printerr("GoLogger Error: Attempting to open directory (", PLAYER_PATH, ") to find player.log -> Error[", _err, "]")
					return
			else: 
				var _files = _dir.get_files()
				var _newest_file = str(PLAYER_PATH + _files[_files.size() -1])
				var _fr = FileAccess.open(_newest_file, FileAccess.READ)
				if !_fr:
					var _err = FileAccess.get_open_error() 
					if _err != OK: 
						if GoLogger.debug_warnings_errors: printerr("GoLogger Error: Reading player.log file -> Error[", _err, "].") 
						return
				
				var _content = _fr.get_as_text()
				_fr.close() 
				if GoLogger.end_session_condition == 1 or GoLogger.end_session_condition == 3:
					if _content.length() > GoLogger.session_character_limit:
						match GoLogger.end_session_behavior:
							0:
								stop_session(0)
								start_session(0)
							1: stop_session(0)
							2: _content = ""
				
				var _f = FileAccess.open(_newest_file, FileAccess.WRITE)
				if !_f:
					var _ferr = FileAccess.get_open_error()  
					if _ferr != OK: 
						if GoLogger.debug_warnings_errors: printerr("GoLogger Error: Writing to player.log file -> Error[", _ferr, "].")
						return
				var _timestamp : String = str("\t[", Time.get_time_string_from_system(utc), "] ") 
				var _s := str(_content, _timestamp + log_entry if include_timestamp else "\t" + log_entry)
				_f.store_line(_s) 
				GoLogger.current_player_char_count = _s.length()
				_f.close()


## Stops the current session. Preventing further entries to be logged. In order to log again, a new session must be started using [code]start_session()[/code]. Doing so will create a new file to log into.
static func stop_session( utc : bool = true, include_timestamp : bool = true) -> void:
	printerr("stop() called")
	if GAME_PATH != null and GAME_PATH != "":
		if GoLogger.session_status:
			var _dir = DirAccess.open(GAME_PATH)
			if !_dir:
				var _err = DirAccess.get_open_error()
				if _err != OK: 
					if GoLogger.debug_warnings_errors: printerr("GoLogger Error. Opening directory to stop the current session (", GAME_PATH, ")")
					return
			else:
				var _files = _dir.get_files()
				var _newest_file = str(GAME_PATH + _files[_files.size() -1])
				print("stop_session() > newest game file = ", _newest_file)
				var _fr = FileAccess.open(_newest_file, FileAccess.READ)
				if !_fr:
					var _err = FileAccess.get_open_error()
					if _err != OK: 
						if GoLogger.debug_warnings_errors: printerr("GoLogger Error: Reading game.log file -> Error[", _err, "]")
						return
				
				var _content = _fr.get_as_text()
				_fr.close()
				var _f = FileAccess.open(_newest_file, FileAccess.WRITE)
				if !_f:
					var _err = FileAccess.get_open_error()
					if _err != OK:
						if GoLogger.debug_warnings_errors: printerr("GoLogger Error: Writing to game.log to end session -> Error[", _err, "]")
						return
				
				var _timestamp : String = str("[", Time.get_time_string_from_system(utc), "] Stopped  log session.") 
				var _s := str(_content, _timestamp if include_timestamp else "Stopped log session.")
				_f.store_line(_s)
				GoLogger.current_game_char_count = _s.length()
				_f.close()
					
	if PLAYER_PATH != null and PLAYER_PATH != "": 
		if GoLogger.session_status:
			var _dir = DirAccess.open(PLAYER_PATH)
			if !_dir:
				var _err = DirAccess.get_open_error()
				if _err != OK: 
					if GoLogger.debug_warnings_errors: printerr("GoLogger Error: Unable to open log directory (", PLAYER_PATH, ") -> Error[", _err,"]")
					return
			else:
				var _files = _dir.get_files()
				var _newest_file = str(PLAYER_PATH + _files[_files.size() -1])
				var _fr = FileAccess.open(_newest_file, FileAccess.READ)
				if !_fr:
					var _err = FileAccess.get_open_error()
					if _err != OK: 
						if GoLogger.debug_warnings_errors: printerr("GoLogger Error: Reading game.log file -> Error[", _err, "]")
						return
				var _content = _fr.get_as_text()
				_fr.close()
				var _f = FileAccess.open(_newest_file, FileAccess.WRITE)
				if !_f:
					var _err = FileAccess.get_open_error()
					if _err != OK:
						if GoLogger.debug_warnings_errors: printerr("GoLogger Error: Writing to game.log to end session -> Error[", _err, "]")
						return
				var _timestamp : String = str("[", Time.get_time_string_from_system(utc), "] Stopped log session.") 
				var _s := str(_content, _timestamp if include_timestamp else "Stopped log session.")
				_f.store_line(_s)
				GoLogger.current_player_char_count = _s.length()
				_f.close()
	GoLogger.toggle_session_status.emit(false)
	GoLogger.session_status_changed.emit()
