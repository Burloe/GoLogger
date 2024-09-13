extends Node
class_name Log

## Handles session logic and logging entries into .log files.
##
## For installation, setup and how to use instructions, see the README.md or https://github.com/Burloe/GoLogger

## These paths can be accessed by selecting Project > Open User Data Folder in the top-left.
const GAME_PATH = "user://logs/gamelogs/" ## Path where .log files are created/stored. Will create the directiry if it doesn't exist
const PLAYER_PATH = "user://logs/playerlogs/" ## Path where .log files are created/stored. Will create the directiry if it doesn't exist
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


## Initiates a log session, recording game events in the .log file. [param category] denotes the file where the entry is logged. [param utc] will force the date and time format to UTC[yy,mm,ddThh:mm:ss]. [param space] will use a space to separate date and time instead of a "T".[br][b]Note:[/b][br]    You cannot start one session without stopping the previous. Attempting it will do nothing.
static func start_session(category : int, utc : bool = true, space : bool = true) -> void:
	# Note: Opening with WRITE truncates previous contents
	match category:
		0: # GAME
			if GoLogger.game_session_status:
				push_warning("GoLogger Warning: Attempted to start new Game log session before stopping the previous.")
				return
			else:
				var dir = DirAccess.open(GAME_PATH)
				if !dir:
					printerr("GoLogger Error: Unable to open file directory (", GAME_PATH, ")")
					# Attempting to create the directory
					var error = DirAccess.make_dir_absolute(GAME_PATH)
					if error != OK:
						printerr("GoLogger Error: Failed to create directory (", GAME_PATH, ") -> Error[", error,"]")
				else: # dir is null > open was unsuccessful
					var files = dir.get_files() # Get all files(excluding directories)
					if files.size() >= GoLogger.max_file_count:
						files.sort()
						# Delete the oldest file
						var old_file = files[0]
						var delete_err = dir.remove(GAME_PATH + old_file)
						if delete_err != OK:
							printerr("GoLogger Error: Failed to delete file (", old_file, ") -> Error[", delete_err,"]")
					# Create a new log file
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
				if !dir: # dir is null > open was unsuccessful
					printerr("GoLogger Error: Unable to open file directory (", PLAYER_PATH, ")")
					# Attempting to create the directory
					var error = DirAccess.make_dir_absolute(PLAYER_PATH)
					if error != OK:
						# If you encounter Error[32], a conflicting file or directory already exists. Change path name to fix.
						push_error("GoLogger Error: Failed to create directory (", PLAYER_PATH, ") -> Error[", error,"]")
				else:
					var files = dir.get_files() # Get all files, excluding directories
					if files.size() >= GoLogger.max_file_count:
						files.sort()
						# Delete the oldest file
						var old_file = files[0]
						var delete_err = dir.remove(PLAYER_PATH + old_file)
						if delete_err != OK:
							printerr("GoLogger Error: Failed to delete file (", old_file, ") -> Error[", delete_err,"]")
					# Create a new log file
					var log_filepath = PLAYER_PATH + get_file_name("player")
					var file = FileAccess.open(log_filepath, FileAccess.WRITE)
					if file:
						file.store_line(str( "Player Log Session Started[", Time.get_datetime_string_from_system(utc, space), "]:"))
						file.close()
						GoLogger.toggle_session_status.emit(1, true)
					else:
						printerr("GoLogger Error: Failed to create log file (", log_filepath, ").")


## Stores a log entry into the 'game/ui/player.log' file. [param date_time_flag] is used to specify the type of date and time format you want your entries tagged with.
##[codeblock] 0 = date + time + log entry
## 1 = time + log entry
## 2 = log entry [/codeblock]
## [param utc] will convert the date and time into a unified UTC format as opposed to your or your players local date/time format.
## [param space] will use a space to separate date and time in the tag. If false, they are separated with a "T"(2024-04-29T14:38:01).
static func entry(category : int, log_entry : String, date_time_flag : int = 0, utc : bool = true, space : bool = true) -> void:
	match category:
		0: # Game Log
			if !GoLogger.game_session_status:
				push_warning("GoLogger Warning: Attempted to log entry into game.log but session is run started. Remember to call 'start_session(0)' in a _ready() function.")
				return
			elif !FileAccess.file_exists(GAME_PATH): # File doesn't exist, create one by calling start_session()
				start_session(0)
			# Get and store previous log entries in _c
			var _flg = FileAccess.open(GAME_PATH, FileAccess.READ)
			var _c = _flg.get_as_text()
			_flg.close()
			# Add the previous content > Add the new entry with the proper date format as specified in the call
			var _fg = FileAccess.open(GAME_PATH, FileAccess.WRITE)
			var _dt : String
			match date_time_flag:
				0: _dt = str("\t[", Time.get_datetime_string_from_system(utc, space), "] ")
				1: _dt = str("\t[", Time.get_date_string_from_system(utc), ") ")
				2: _dt = str("\t[", Time.get_time_string_from_system(utc), "] ")
				3: _dt = str("\t")
			_fg.store_line(str(_c, _dt, log_entry))
			_fg.close()

		1: # Player Log
			if !GoLogger.player_session_status:
				push_warning("GoLogger Warning: Attempted to log entry into player.log but session was not started. Call 'start_session(1)' in a _ready() function.")
				return
			elif !FileAccess.file_exists(PLAYER_PATH): # File doesn't exist, create one by calling start_session()
				start_session(2)
			# Get and store previous log entries in _c
			var _flp = FileAccess.open(PLAYER_PATH, FileAccess.READ)
			var _c = _flp.get_as_text()
			_flp.close()
			# Add the previous content > Add the new entry with the proper date format as specified in the call
			var _fp = FileAccess.open(PLAYER_PATH, FileAccess.WRITE)
			var _dt : String
			match date_time_flag:
				0: _dt = str("\t[", Time.get_datetime_string_from_system(utc, space), "] ")
				1: _dt = str("\t[", Time.get_time_string_from_system(utc), "] ")
				2: _dt = str("\t")
			_fp.store_line(str(_c, _dt, log_entry))
			_fp.close()


## Stops the current session. Preventing further entries to be logged.
static func stop_session(category : int, utc : bool = true, space : bool = true) -> void:
		match category:
			0: # GAME
				if GoLogger.game_session_status:
					if FileAccess.file_exists(GAME_PATH):
						var _flg = FileAccess.open(GAME_PATH, FileAccess.READ)
						var _content : String = str(_flg.get_as_text())
						_flg.close()
						var _fg = FileAccess.open(GAME_PATH, FileAccess.WRITE)
						var _date : String = str("[", Time.get_datetime_string_from_system(utc, space), "] Stopped log Session.")
						_fg.store_line(str(_content, _date))
						_fg.close()
						GoLogger.toggle_session_status.emit(0, false)
			1: # PLAYER
				if GoLogger.player_session_status:
					if FileAccess.file_exists(PLAYER_PATH):
						var _flp = FileAccess.open(PLAYER_PATH, FileAccess.READ)
						var _content : String = str(_flp.get_as_text())
						_flp.close()
						var _fp = FileAccess.open(PLAYER_PATH, FileAccess.WRITE)
						var _date : String = str("[", Time.get_datetime_string_from_system(utc, space), "] Stopped log session.")
						_fp.store_line(str(_content, _date))
						_fp.close()
						GoLogger.toggle_session_status.emit(2, false)
