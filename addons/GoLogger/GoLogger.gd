extends Node

## I recommend you merge this code into one of your existing autoloads 

signal toggle_session_status(category : int, status : bool) ## Session Status is changed whenever a session is started or stopped.
signal session_status_changed ## Emitted after session status is changed. Not used but can be useful if you plan on expanding the system. 
var max_file_count = 3 ## Sets the max number of log files. Deletes the oldest log file when a new is created.
var game_session_status: bool = false ## Flags whether a log session is in progress or not.
var player_session_status: bool = false ## Flags whether a log session is in progress or not.

func _ready() -> void:
	toggle_session_status.connect(_on_toggle_session_status)
	Log.start_session(0)
	Log.start_session(1)

## Toggles the session status between true/false upon signal [signal GoLogger.toggle_session_status] emitting. 
func _on_toggle_session_status(category : int, status : bool) -> void:
	match category:
		0: game_session_status = status
		1: player_session_status = status
	session_status_changed.emit()
