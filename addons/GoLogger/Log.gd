extends Node
class_name Log

## Handles session logic and logging entries into .log files.
##
## For installation, setup and how to use instructions, see the README.md or https://github.com/Burloe/GoLogger

const GAME_FILE = "user://logs/game.log" ## This file can be accessed by selecting Project > Open User Data Folder in the top-left.
const UI_FILE = "user://logs/ui.log"
const PLAYER_FILE = "user://logs/player.log"
# Usually located in C:\Users\User\AppData\Roaming\Godot\app_userdata\Project\logs


## Initiates a log session, recording game events. [param category] denotes the category of entry. [param utc] will force the date and time format to UTC[yy,mm,ddThh:mm:ss]. [param space] will use a space to separate date and time instead of a "T".[br][b]Note:[/b][br]    You cannot start one session without stopping the previous. Attempting it will do nothing.
static func start_session(category : int, utc : bool = true, space : bool = true) -> void:
	# Note: Opening with WRITE truncates previous contents
	match category:
		0:
			if GoLogger.game_session_status:
				push_warning("GoLogger Warning: Attempted to start new Game logsession before stopping the previous.")
				return
			else:
				var _fg = FileAccess.open(GAME_FILE, FileAccess.WRITE)
				_fg.store_line(str("[", Time.get_datetime_string_from_system(utc, space), "] New Game Session:"))
				_fg.close()
				GoLogger.toggle_session_status.emit(0, true)
		1:
			if GoLogger.ui_session_status:
				push_warning("GoLogger Warning: Attempted to start new UI log session before stopping the previous.")
				return
			else:
				var _fui = FileAccess.open(UI_FILE, FileAccess.WRITE)
				_fui.store_line(str("[", Time.get_datetime_string_from_system(utc, space), "] New UI Session:"))
				_fui.close()
				GoLogger.toggle_session_status.emit(1, true)
		2:
			if GoLogger.player_session_status:
				push_warning("GoLogger Warning: Attempted to start new Player log session before stopping the previous.")
				return
			else:
				var _fp = FileAccess.open(PLAYER_FILE, FileAccess.WRITE)
				_fp.store_line(str("[", Time.get_datetime_string_from_system(utc, space), "] New Players Session:"))
				_fp.close()
				GoLogger.toggle_session_status.emit(2, true)


## Stores a log entry into the 'game/ui/player.log' file. [param date_time_flag] is used to specify if the date and time format you want included with your entries.
##[codeblock] 0 = date + time + log entry
## 1 = time + log entry
## 2 = log entry [/codeblock]
static func entry(category : int, log_entry : String, date_time_flag : int = 0, utc : bool = true, space : bool = true) -> void:
	match category:
		0: # Game Log
			if !GoLogger.game_session_status:
				push_warning("GoLogger Warning: Attempted to log entry into game.log but session is run started. Remember to call 'start_session(0)' in a _ready() function.")
				return
			elif !FileAccess.file_exists(GAME_FILE): # File doesn't exist, create one by calling start_session()
				start_session(0)
			# Get and store previous log entries in _c
			var _fl = FileAccess.open(GAME_FILE, FileAccess.READ)
			var _c = _fl.get_as_text()
			_fl.close()
			# Add the old content > Add the new entry with the proper date format as specified in the call
			var _f = FileAccess.open(GAME_FILE, FileAccess.WRITE)
			var _dt : String
			match date_time_flag:
				0: _dt = str("\t[", Time.get_datetime_string_from_system(utc, space), "] ")
				1: _dt = str("\t[", Time.get_time_string_from_system(utc), "] ")
				2: _dt = str("\t")
			_f.store_line(str(_c, _dt, log_entry))
			_f.close()

		1: # UI Log
			if !GoLogger.ui_session_status:
				push_warning("GoLogger Warning: Attempted to log entry into ui.log but session is run started. Remember to call 'start_session(1)' in a _ready() function.")
				return
			elif !FileAccess.file_exists(UI_FILE): # File doesn't exist, create one by calling start_session()
				start_session(1)
			# Get and store previous log entries in _c
			var _fl = FileAccess.open(UI_FILE, FileAccess.READ)
			var _c = _fl.get_as_text()
			_fl.close()
			# Add the old content > Add the new entry with the proper date format as specified in the call
			var _f = FileAccess.open(UI_FILE, FileAccess.WRITE)
			var _dt : String
			match date_time_flag:
				0: _dt = str("\t[", Time.get_datetime_string_from_system(utc, space), "] ")
				1: _dt = str("\t[", Time.get_time_string_from_system(utc), "] ")
				2: _dt = str("\t")
			_f.store_line(str(_c, _dt, log_entry))
			_f.close()

		2: # Player Log
			if !GoLogger.player_session_status:
				push_warning("GoLogger Warning: Attempted to log entry into player.log but session is run started. Call 'start_session(2)' in a _ready() function.")
				return
			elif !FileAccess.file_exists(PLAYER_FILE): # File doesn't exist, create one by calling start_session()
				start_session(2)
			# Get and store previous log entries in _c
			var _fl = FileAccess.open(PLAYER_FILE, FileAccess.READ)
			var _c = _fl.get_as_text()
			_fl.close()
			# Add the old content > Add the new entry with the proper date format as specified in the call
			var _f = FileAccess.open(PLAYER_FILE, FileAccess.WRITE)
			var _dt : String
			match date_time_flag:
				0: _dt = str("\t[", Time.get_datetime_string_from_system(utc, space), "] ")
				1: _dt = str("\t[", Time.get_time_string_from_system(utc), "] ")
				2: _dt = str("\t")
			_f.store_line(str(_c, _dt, log_entry))
			_f.close()


## Stops the current session. Preventing further entries to be logged.
static func stop_session(category : int, utc : bool = true, space : bool = true) -> void:
		match category:
			0: # GAME
				if GoLogger.game_session_status:
					if FileAccess.file_exists(GAME_FILE):
						var _fr = FileAccess.open(GAME_FILE, FileAccess.READ)
						var _content : String = str(_fr.get_as_text())
						_fr.close()
						var _fg = FileAccess.open(GAME_FILE, FileAccess.WRITE)
						var _date : String = str("[", Time.get_datetime_string_from_system(utc, space), "] Stopped log Session.")
						_fg.store_line(str(_content, _date))
						GoLogger.toggle_session_status.emit(0, false)
			1: # UI
				if GoLogger.ui_session_status:
					if FileAccess.file_exists(UI_FILE):
						var _fr = FileAccess.open(UI_FILE, FileAccess.READ)
						var _content : String = str(_fr.get_as_text())
						_fr.close()
						var _fui = FileAccess.open(UI_FILE, FileAccess.WRITE)
						var _date : String = str("[", Time.get_datetime_string_from_system(utc, space), "] Stopped log Session.")
						_fui.store_line(str(_content, _date))
						GoLogger.toggle_session_status.emit(1, false)
			2: # PLAYER
				if GoLogger.player_session_status:
					if FileAccess.file_exists(PLAYER_FILE):
						var _fr = FileAccess.open(PLAYER_FILE, FileAccess.READ)
						var _content : String = str(_fr.get_as_text())
						_fr.close()
						var _fp = FileAccess.open(PLAYER_FILE, FileAccess.WRITE)
						var _date : String = str("[", Time.get_datetime_string_from_system(utc, space), "] Stopped log session.")
						_fp.store_line(str(_content, _date))
						GoLogger.toggle_session_status.emit(2, false)
