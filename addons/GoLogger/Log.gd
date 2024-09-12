extends Node
class_name Log

## Log class that handles the interactions with the .log files.
##
## For setup instructions, see the README.md or https://github.com/Burloe/GoLogger

const DEVFILE = "res://addons/GoLogger/game.log" ## Change this location to anywhere you want in your project files
const FILE = "user://log/game.log" ## This file can be accessed by selecting Project > Open User Data Folder in the top-left. 
# Usually located in C:\Users\User\AppData\Roaming\Godot\app_userdata\Project\logs


## Starts a log session, recording game events. 
static func start_session() -> void:
	# Opening a file with WRITE will clear it of previous contents. 
	var _f = FileAccess.open(DEVFILE if GoLogger.log_on_dev else FILE, FileAccess.WRITE) 
	_f.store_line(str("[", Time.get_datetime_string_from_system(true, true), "] New session:")) 
	GoLogger.session_status_changed.emit(true)

## Stops the current session.
static func stop_session() -> void:
	if GoLogger.log_session:
		if FileAccess.file_exists(DEVFILE if GoLogger.log_on_dev else FILE):
			var _file = FileAccess.open(DEVFILE if GoLogger.log_on_dev else FILE, FileAccess.READ)
			var _content = _file.get_as_text()
			_file.close()
			
			var _f = FileAccess.open(DEVFILE if GoLogger.log_on_dev else FILE, FileAccess.WRITE)
			var _date : String = str("[", Time.get_datetime_string_from_system(true, true), "] Stopped session.") 
			GoLogger.session_status_changed.emit(false)


## Stores a log entry into the [code]gamelog.txt[/code] file. [param date_time_flag] is used to specify if the date and time format you want included with your entries.
##[codeblock] 0 = date + time + log entry
## 1 = time + log entry
## 2 = log entry [/codeblock]
static func entry(log_entry : String, date_time_flag : int = 0) -> void:
	if GoLogger.log_session:
		if FileAccess.file_exists(DEVFILE if GoLogger.log_on_dev else FILE):
			# Store the old contents
			var _file = FileAccess.open(DEVFILE if GoLogger.log_on_dev else FILE, FileAccess.READ)
			var _content = _file.get_as_text()
			_file.close()
			# Add the new log_entry
			var _f = FileAccess.open(DEVFILE if GoLogger.log_on_dev else FILE, FileAccess.WRITE)
			var _dt : String
			match date_time_flag:
				0: _dt = str("\t[", Time.get_datetime_string_from_system(true, true), "] ")
				1: _dt = str("\t[", Time.get_time_string_from_system(true), "] ")
				2: _dt = ""
			_f.store_line(str(_content, _dt, log_entry))
			_f.close()
		else: # File doesn't exist > Create new one 
			var _file = FileAccess.open(DEVFILE if GoLogger.log_on_dev else FILE, FileAccess.WRITE)
			var _date : String = str("\t[", Time.get_datetime_string_from_system( true, true), "]: ")
			_file.store_line(str("New log started [", Time.get_datetime_string_from_system( true, true), "]\n\t[", Time.get_datetime_string_from_system( true, true), "]: "))
