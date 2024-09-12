extends Node

## I recommend you merge this code into one of your existing autoloads 

signal toggle_session_status(category : int, status : bool) ## Session Status is changed whenever a session is started or stopped.
signal session_status_changed ## Emitted after session status is changed. Not used but can be useful if you plan on expanding the system. 
var game_session_status: bool = false ## Flags whether a log session is in progress or not. 
var ui_session_status: bool = false ## Flags whether a log session is in progress or not. 
var player_session_status: bool = false ## Flags whether a log session is in progress or not. 
var log_in_devfile : bool = true ## Flags whether or not logs are saved using the [param FILE](false) or [param DEVFILE](true).

func _ready() -> void:
	toggle_session_status.connect(_on_toggle_session_status)
	Log.start_session(0)
	Log.start_session(1)
	Log.start_session(2)


func _on_toggle_session_status(category : int, status : bool) -> void:
	match category:
		0: game_session_status = status
		1: ui_session_status = status
		2: player_session_status = status
	session_status_changed.emit()
