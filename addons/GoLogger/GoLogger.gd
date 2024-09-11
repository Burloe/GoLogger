extends Node

## I recommend you merge this code into one of your existing autoloads 

signal session_status_changed(status : bool) ## Session Status is changed whenever a session is started or stopped.
var session_status: bool = false ## Flags whether a log session is in progress or not. 
var log_in_devfile : bool = true ## Flags whether or not logs are saved using the [param FILE](false) or [param DEVFILE](true).

func _ready() -> void:
	session_status_changed.connect(_on_session_status_changed)
	Log.start_session()


func _on_session_status_changed(status : bool) -> void:
	session_status = status
