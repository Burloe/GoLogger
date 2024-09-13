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

## Returns the log entries of the given file.
static func get_file_contents(folder_path : String) -> String:
	var f = FileAccess.open(folder_path, FileAccess.READ)
	var c := f.get_as_text()
	f.close()
	return c


## Initiates a log session, recording game events in the .log file. [param category] denotes the file where the entry is logged. [param utc] will force the date and time format to UTC[yy,mm,ddThh:mm:ss]. [param space] will use a space to separate date and time instead of a "T".[br][b]Note:[/b][br]    You cannot start one session without stopping the previous. Attempting it will do nothing.
static func start_session(category : int, utc : bool = true, space : bool = true) -> void: 
	match category:
		0: # GAME
			if GoLogger.game_session_status:
				push_warning("GoLogger Warning: Attempted to start new Game log session before stopping the previous.")
				return
			else:
				var dir = DirAccess.open(GAME_PATH)
				if !dir:
					printerr("GoLogger Error: Unable to open file directory (", GAME_PATH, ")") 
					var error = DirAccess.make_dir_absolute(GAME_PATH)
					if error != OK:
						printerr("GoLogger Error: Failed to create directory (", GAME_PATH, ") -> Error[", error,"]")
				else:  
					var files = dir.get_files() 
					if files.size() >= GoLogger.max_file_count:
						files.sort() 
						var old_file = files[0]
						var delete_err = dir.remove(GAME_PATH + old_file)
						if delete_err != OK:
							printerr("GoLogger Error: Failed to delete file (", old_file, ") -> Error[", delete_err,"]") 
					var log_filepath = GAME_PATH + get_file_name("game")
					var file = FileAccess.open(log_filepath, FileAccess.WRITE)
					if file:
						file.store_line(str( "Game Log Session Started[", Time.get_datetime_string_from_system(utc, space), "]:"))
						file.close()
						GoLogger.toggle_session_status.emit(0, true)
					else:
						printerr("GoLogger Error: Failed to create log file (", log_filepath, ").")
		1: # PLAYER
			if GoLogger.player_session_status:
				push_warning("GoLogger Warning: Attempted to start new Player log session before stopping the previous.")
				return
			else:
				var dir = DirAccess.open(PLAYER_PATH)
				if !dir: 
					printerr("GoLogger Error: Unable to open file directory (", PLAYER_PATH, ")") 
					var error = DirAccess.make_dir_absolute(PLAYER_PATH) 
					if error != OK: push_error("GoLogger Error: Failed to create directory (", PLAYER_PATH, ") -> Error[", error,"]")
				else:
					var files = dir.get_files() 
					if files.size() >= GoLogger.max_file_count:
						files.sort() 
						var old_file = files[0]
						var delete_err = dir.remove(PLAYER_PATH + old_file)
						if delete_err != OK: printerr("GoLogger Error: Failed to delete file (", old_file, ") -> Error[", delete_err,"]") 
					var log_filepath = PLAYER_PATH + get_file_name("player")
					var file = FileAccess.open(log_filepath, FileAccess.WRITE)
					if file:
						file.store_line(str( "Player Log Session Started[", Time.get_datetime_string_from_system(utc, space), "]:"))
						file.close()
						GoLogger.toggle_session_status.emit(1, true)
					else:
						printerr("GoLogger Error: Failed to create log file (", log_filepath, ").")


## Stores a log entry into the 'game/ui/player.log' file.[br]
## [param timestamp] is used to specify the type of date and time format you want your entries tagged with.[br]
## [param utc] will convert the time into a unified UTC format as opposed to your or your players local time format.
static func entry(file : int, log_entry : String, include_timestamp : bool = true, utc : bool = true) -> void:
	match file:
		0: # Game Log
			if !GoLogger.game_session_status:
				push_warning("GoLogger Warning: Attempted to log Game entry without starting a session. Remember to call 'start_session(0)' in a _ready() function.")
				return
				
			var dir = DirAccess.open(GAME_PATH) 
			if !dir:
				var err = DirAccess.get_open_error()
				if err != OK:
					printerr("GoLogger Error: Attempting to log entry. Opening directory (", GAME_PATH, ") to find game.log")
					return
			else: 
				var _files = dir.get_files()
				var _newest_file = str(GAME_PATH + _files[_files.size() -1]) 
				var _fr = FileAccess.open(_newest_file, FileAccess.READ)# Open last newest file with READ
				if !_fr:
					var _err = FileAccess.get_open_error() 
					if _err != OK: 
						printerr("GoLogger Error: Reading game.log file -> Error[", _err, "].") 
						return
				var _content = _fr.get_as_text() # Store old log entries before the file is truncated
				_fr.close()
				var _f = FileAccess.open(_newest_file, FileAccess.WRITE) 
				if !_f: 
					var _ferr = FileAccess.get_open_error()  
					if _ferr != OK: 
						printerr("GoLogger Error: Writing to game.log file -> Error[", _ferr, "].")
						return
				var _timestamp : String = str("\t[", Time.get_time_string_from_system(utc), "] ") 
				# Re-enter old log entries then add the new entry, prefixed with timestamp if include_timestamp allows
				_f.store_line(str(_content, _timestamp + log_entry if include_timestamp else "\t" + log_entry)) 
				_f.close()
				
		1: # Player Log
			if !GoLogger.player_session_status:
				push_warning("GoLogger Warning: Attempted to log Player entry without starting a session. Remember to call 'start_session(0)' in a _ready() function.")
				return
				
			var dir = DirAccess.open(GAME_PATH) 
			if !dir:
				var err = DirAccess.get_open_error()
				if err != OK:
					printerr("GoLogger Error: Attempting to log entry. Opening directory (", GAME_PATH, ") to find player.log")
					return
			else: 
				var _files = dir.get_files()
				var _newest_file = str(GAME_PATH + _files[_files.size() -1])
				var _fr = FileAccess.open(_newest_file, FileAccess.READ)
				if !_fr:
					var _err = FileAccess.get_open_error() 
					if _err != OK: 
						printerr("GoLogger Error: Reading player.log file -> Error[", _err, "].") 
						return
				var _content = _fr.get_as_text()
				_fr.close()
				var _f = FileAccess.open(_newest_file, FileAccess.WRITE)
				if !_f:
					var _ferr = FileAccess.get_open_error()  
					if _ferr != OK: 
						printerr("GoLogger Error: Writing to player.log file -> Error[", _ferr, "].")
						return
				var _timestamp : String = str("\t[", Time.get_time_string_from_system(utc), "] ") 
				_f.store_line(str(_content, _timestamp + log_entry if include_timestamp else "\t" + log_entry)) 
				_f.close()


## Stops the current session. Preventing further entries to be logged. In order to log again, a new session must be started using [code]start_session()[/code]. Doing so will create a new file to log into.
static func stop_session(file : int, utc : bool = true, include_timestamp : bool = true) -> void:
		match file:
			0: # GAME
				if GoLogger.game_session_status:
					var dir = DirAccess.open(GAME_PATH)
					if !dir:
						var err = DirAccess.get_open_error()
						if err != OK: 
							printerr("GoLogger Error. Opening directory to stop the current session (", GAME_PATH, ")")
							return
					else:
						var _files = dir.get_files()
						var _newest_file = str(GAME_PATH + _files[_files.size() -1])
						var _fr = FileAccess.open(_newest_file, FileAccess.READ)
						if !_fr:
							var _err = FileAccess.get_open_error()
							if _err != OK: 
								printerr("GoLogger Error: Reading game.log file -> Error[", _err, "]")
								return
						var _content = _fr.get_as_text()
						_fr.close()
						var _f = FileAccess.open(_newest_file, FileAccess.WRITE)
						if !_f:
							var _err = FileAccess.get_open_error()
							if _err != OK:
								printerr("GoLogger Error: Writing to game.log to end session -> Error[", _err, "]")
								return
						var _timestamp : String = str("[", Time.get_time_string_from_system(utc), "] Stopped Game log session.") 
						_f.store_line(str(_content, _timestamp if include_timestamp else "Stopped Game log session",))
						
			1: # PLAYER
				if GoLogger.player_session_status:
					var dir = DirAccess.open(PLAYER_PATH)
					if !dir:
						var err = DirAccess.get_open_error()
						if err != OK: 
							printerr("GoLogger Error. Opening directory to stop the current session (", PLAYER_PATH, ")")
							return
					else:
						var _files = dir.get_files()
						var _newest_file = str(PLAYER_PATH + _files[_files.size() -1])
						var _fr = FileAccess.open(_newest_file, FileAccess.READ)
						if !_fr:
							var _err = FileAccess.get_open_error()
							if _err != OK: 
								printerr("GoLogger Error: Reading game.log file -> Error[", _err, "]")
								return
						var _content = _fr.get_as_text()
						_fr.close()
						var _f = FileAccess.open(_newest_file, FileAccess.WRITE)
						if !_f:
							var _err = FileAccess.get_open_error()
							if _err != OK:
								printerr("GoLogger Error: Writing to game.log to end session -> Error[", _err, "]")
								return
						var _timestamp : String = str("[", Time.get_time_string_from_system(utc), "] Stopped Game log session.") 
						_f.store_line(str(_content, _timestamp if include_timestamp else "Stopped Game log session",))
