@icon("res://addons/GoLogger/GoLogger.png")
extends Node

#region Documentation & variable declarations
## Responsible for most non-static operations. Make sure that the GoLogger.tscn file is an autoload before using GoLogger. Note that it's the .TSCN we want to be an autoload and not the script file.
##
## The plugin has two safeguard in place in order to prevent potential issues. A character count is performed each time anything is written to the log and a session timer also starts alongside a session. These are turned off by default but does still count the characters and start/stop the timer. Having them enabled/disabled merely determines whether or not it will perform a behaviour once their conditions are fulfilled.[br][br]
## [color=red]WARNING: [br][color=white]When installing the plugin Gologger.tscn should be added as an autoload. Ensure that it's in [code]Project > Project Settings > Globals > Autoload[/code] and if it doesn't appear in the list. Add the "GoLogger.TSCN" scene file. NOT THE ".gd" file, or the plugin won't work.

signal toggle_session_status(status : bool) ## Emitted at the end of [code]Log.start_session()[/code] and [code]Log.end_session[/code]. This signal is responsible for turning sessions on and off.
signal session_status_changed ## Emitted when session status is changed. Use to signal your other scripts that the session is active. 
signal session_timer_started ## Emitted when the [param session_timer] is started.
var project_name : String ## Name of your project/game. Found in "Project Settings > Application > Config > Name"
var project_version : String ## Version of your project. Found in "Project Settings > Application > Config > Version".
@export var disable_errors : bool = true ## Enables/disables all debug warnings and errors
@export var include_name_and_version : bool = true ## Includes the project version at the top of the log file as defined in "Project Settings > Application > Config > Version"
@export var hide_contoller_on_start : bool = false
@export var autostart_session : bool = false ## Starts the session in the '_ready()' function of GoLogger.gd.
@export var file_cap = 3 ## Sets the max number of log files. Deletes the oldest log file in directory when file count exceeds this number.
@export var session_status: bool = false ## Flags whether a log session is in active or not, only meant to hint to see session status in inspector. [br][b]NOT RECOMMENDED TO BE USED TO START AND STOP SESSIONS![/b]

@export_group("Log Management") 
@onready var session_timer: Timer = $SessionTimer ## Timer node that tracks the session time. Will stop and start new sessions on [signal timeout].
## Denotes the method of log management used to prevent long and large .log files. Prevents potential performance issues(see "Preventing too large .log files" in the README for more info).[br]
## [b]1. Entry Limit:[/b] Checks the number of entries in the file when logging a new ones. If entry count exceeds [param entry_count_limit], the oldest entry in file is removed to make room for the new entry.[br]
## [b]2. Session Timer:[/b] Whenever a session is started, the [param session_timer] is started, counting down the [param session_timer_wait_time] value. Upon [signal timeout], the session is stopped and depending on the [param session_timeout_action]. It will either start a new session(creating a new .log file), stop the session only(requires manual restart) or clear the current log of it's contents and continue to log in the same file.[br]
## [b]3. Both Entry Count Limit and Session Timer:[/b] Uses both of the above methods.[br]
## [b]4. None:[/b] Uses no methods of preventing too large files. Not recommended, particularly so if you intend to ship your game with this plugin.
@export_enum("Entry Count Limit", "Session Timer", "Both Entry Limit & Session Timer", "None") var log_manage_method : int = 0
## The log entry count(or line count) limit allowed in the .log file. If entry count exceeds this number, the oldest entry is removed before adding the new.
## [b]Stop & start new session:[/b] Stops the current session and starting a new one. Creates a new .log file to continue log into.[br][b]Stop session only:[/b] Stops the current session without starting a new one. Note that this requires a manual restart which can be done in the Controller, or if you've implemented your own way of starting it.[br][b]Clear current log:[/b] Clears the current .log file of it's previous log entries and continues to log into the same file.
@export_enum("Stop & start new session", "Stop session only", "Clear current log") var session_timeout_action : int = 0
@export var entry_count_limit: int = 100
## Default length of time for a session when [param Session Timer] is enabled
@export var session_timer_wait_time : float = 120.0: 
	set(new):
		session_timer_wait_time = new
		if session_timer != null: session_timer.wait_time = session_timer_wait_time
var current_game_file : String = "" ## .log file associated with the current session
var current_player_file : String = "" ## .log file associated with the current session
#endregion


func _ready() -> void:
	toggle_session_status.connect(_on_toggle_session_status)
	project_name = ProjectSettings.get_setting("application/config/name")
	project_version = ProjectSettings.get_setting("application/config/version")
	if autostart_session:
		print("Starting session using 'start_session()' in GoLogger _ready()")
		Log.start_session()
	if session_timer == null:
		session_timer = Timer.new()
		add_child(session_timer)
		session_timer.owner = self
		session_timer.set_name("SessionTimer")
	session_timer.timeout.connect(_on_session_timer_timeout)
	session_timer.one_shot = false
	session_timer.wait_time = session_timer_wait_time
	session_timer.autostart = false
	


## Signal receiver: Toggles the session status between true/false upon signal [signal GoLogger.toggle_session_status] emitting. 
func _on_toggle_session_status(status : bool) -> void:
	print("Received 'toggle_session_status signal -> ", status)
	session_status = status
	if !status: 
		session_timer.stop()
	else:  
		# Prevent the creation of file on the same timestamp
		await get_tree().create_timer(1.0)
		session_timer.start(autostart_session)
		session_timer_started.emit()
	session_status_changed.emit()

## Signal receiver: Stops and possibly starts the session when [param session_timer]s [signal timeout] signal is emitted. 
func _on_session_timer_timeout() -> void:
	if log_manage_method == 1 or log_manage_method == 2:
		Log.stop_session() 
		if session_timeout_action == 1:
			Log.start_session()  
	session_timer.wait_time = session_timer_wait_time
