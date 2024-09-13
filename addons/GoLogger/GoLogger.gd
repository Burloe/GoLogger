@icon("res://addons/GoLogger/GoLogger.png")
extends Node
#TODO: toggle the controller on or off
## Responsible for most non-static operations. Make sure that the GoLogger.tscn file is an autoload before using GoLogger. Note that it's the .TSCN we want to be an autoload and not the script file.

## Emitted at the end of [code]Log.start_session()[/code] and [code]Log.end_session[/code]. This signal is responsible for turning sessions on and off.
signal toggle_session_status(type : int, status : bool) 
signal session_status_changed ## Emitted when session status is changed. 
signal session_timer_started ## Emitted when the [param session_timer] is started.
@onready var session_timer: Timer = $SessionTimer ## Timer node that tracks the session time. Will stop and start new sessions on [signal timeout].
@export var autostart_logs : bool = true ## Sessions will autostart when running your project.
@export var max_file_count = 3 ## Sets the max number of log files. Deletes the oldest log file in directory when file count exceeds this number.
@export var game_session_status: bool = false ## Flags whether a log session is in progress or not, only meant to be a visual hint to see if the session is started or not. [br][b]NOT RECOMMENDED TO BE USED TO START AND RESTART SESSIONS![/b]
@export var player_session_status: bool = false ## Flags whether a log session is in progress or not, only meant to be a visual hint to see if the session is started or not. [br][b]NOT RECOMMENDED TO BE USED TO START AND RESTART SESSIONS![/b]
@export_group("Session Timer")
@export var enable_session_timer : bool = false:
	set(new):
		enable_session_timer = new
		session_timer.autostart = true
		session_timer.set_wait_time(session_time)
@export var session_time : float = 120.0: ## Default length of time for a session when [param Session Timer] is enabled 
	set(new):
		session_time = new
		session_timer.set_wait_time(session_time)



func _ready() -> void:
	toggle_session_status.connect(_on_toggle_session_status)
	if autostart_logs:
		Log.start_session(0)
		Log.start_session(1)
	if session_timer == null:
		session_timer = Timer.new()
		add_child(session_timer)
		session_timer.owner = self
		session_timer.set_name("SessionTimer")
	session_timer.timeout.connect(_on_session_timer_timeout)


## Toggles the session status between true/false upon signal [signal GoLogger.toggle_session_status] emitting. 
func _on_toggle_session_status(type : int, status : bool) -> void:
	match type:
		0: 
			game_session_status = status
			if !status: Log.stop_session(type)
		1: 
			player_session_status = status
			if !status: Log.stop_session(type)
	if status and enable_session_timer and session_timer.is_stopped():
		session_timer.start(session_time)
		session_timer_started.emit()
	if !status and enable_session_timer and !session_timer.is_stopped():
		session_timer.stop()
	session_status_changed.emit()


func _on_session_timer_timeout() -> void:
	Log.stop_session(0)
	Log.start_session(0)
	Log.stop_session(1)
	Log.start_session(1)
