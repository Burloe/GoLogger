extends Node
class_name Log

## Log class that handles the interactions with the .log files.
##
## For setup instructions, see the README.md or https://github.com/Burloe/GoLogger

const DEVFILE = "res://GoLogger/game.log" ## Change this location to anywhere you want in your project files
const FILE = "user://log/game.log" ## This file can be accessed by selecting Project > Open User Data Folder in the top-left. 
# Usually located in C:\Users\User\AppData\Roaming\Godot\app_userdata\Project\logs


## Initializes the logging of game events. Called by SaveManager in the _ready() function or after [param clear_log()] is completed.
static func start_session() -> void:
	# Opening a file with WRITE will clear it of previous contents. 
	var _f = FileAccess.open(DEVFILE if GoLogger.log_on_dev else FILE, FileAccess.WRITE) 
	_f.store_line(str("[", Time.get_datetime_string_from_system(true, true), "] New session:")) 
	GoLogger.session_status_changed.emit(true)


static func stop_session() -> void:
	if GoLogger.log_session:
		if FileAccess.file_exists(DEVFILE if GoLogger.log_on_dev else FILE):
			var _file = FileAccess.open(DEVFILE if GoLogger.log_on_dev else FILE, FileAccess.READ)
			var _content = _file.get_as_text()
			_file.close()
			
			var _f = FileAccess.open(DEVFILE if GoLogger.log_on_dev else FILE, FileAccess.WRITE)
			var _date : String = str("[", Time.get_datetime_string_from_system(true, true), "] Stopped session.") 
			GoLogger.session_status_changed.emit(false)


## Stores a log entry into the [code]gamelog.txt[/code] file. By default, the system will log the date and time on each log entry. Optionally, this can be prevented by calling function with 'false'. 
static func entry(log_entry : String, include_date_time : bool = true) -> void:
	if GoLogger.log_session:
		if FileAccess.file_exists(DEVFILE if GoLogger.log_on_dev else FILE):
			# Store the old contents
			var _file = FileAccess.open(DEVFILE if GoLogger.log_on_dev else FILE, FileAccess.READ)
			var _content = _file.get_as_text()
			_file.close()
			# Add the new log_entry
			var _f = FileAccess.open(DEVFILE if GoLogger.log_on_dev else FILE, FileAccess.WRITE)
			var _date : String = str("\t[", Time.get_datetime_string_from_system( true, true), "]: ")
			_f.store_line(str(_content, _date if include_date_time else ": ", log_entry))
			_f.close()
		else: # File doesn't exist > Create new one 
			var _file = FileAccess.open(DEVFILE if GoLogger.log_on_dev else FILE, FileAccess.WRITE)
			var _date : String = str("\t[", Time.get_datetime_string_from_system( true, true), "]: ")
			_file.store_line(str("New log started [", Time.get_datetime_string_from_system( true, true), "]\n\t[", Time.get_datetime_string_from_system( true, true), "]: "))


## Clears session and starts a new one.
static func clear_session() -> void:
	var _f = FileAccess.open(DEVFILE if Global.log_on_dev else FILE, FileAccess.WRITE)
	_f.close()
	start_session()
