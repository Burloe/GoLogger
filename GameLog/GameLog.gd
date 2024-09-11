extends Node
class_name GameLog

## Class that logs events into a single source which can be used for testing and debugging.
##
## This was created because the output prints are quickly becoming unmanageable and thus, it's better to have a separate log file that I can examine IF an error occurs with something I don't need to be reported everytime I run the game. 

const FILE = "res://SCRIPTS/GameLog/game.log"
const PRODUCTION_FILE = "user://log/game.log"

## Initializes the logging of game events. Called by SaveManager in the _ready() function or after [param clear_log()] is completed.
static func start_session() -> void:
	# Opening a file with WRITE will clear it of previous contents. 
	var _f = FileAccess.open(FILE, FileAccess.WRITE) 
	_f.store_line(
		str(
			#? Add game version, steam user data and other telemetries
			"[", Time.get_datetime_string_from_system(true, true), "] New session:"
			)
		)

## Stores a log entry into the [code]gamelog.txt[/code] file. By default, the system will log the date and time on each log entry. Optionally, this can be prevented by calling function with 'false'. 
static func log(entry : String, include_date_time : bool = true) -> void:
	if FileAccess.file_exists(FILE):
		# Store the old contents
		var _file = FileAccess.open(FILE, FileAccess.READ)
		var _content = _file.get_as_text()
		_file.close()

		# Add the new entry
		var _f = FileAccess.open(FILE, FileAccess.WRITE)
		var _date : String = str("\t[", Time.get_datetime_string_from_system( true, true), "]: ")
		_f.store_line(str(_content, _date if include_date_time else ": ", entry))
		_f.close()
	
	else: # File doesn't exist > Create new one 
		var _file = FileAccess.open(FILE, FileAccess.WRITE)
		var _date : String = str("\t[", Time.get_datetime_string_from_system( true, true), "]: ")
		_file.store_line(str("New log started [", Time.get_datetime_string_from_system( true, true), "]\n\t[", Time.get_datetime_string_from_system( true, true), "]: "))
	
## Clears session and starts a new one.
static func clear_session() -> void:
	var _f = FileAccess.open(FILE, FileAccess.WRITE)
	_f.close()
	start_session()
