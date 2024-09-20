@icon("res://addons/GoLogger/GoLoggerIcon.png")
extends Node

#region Documentation & variable declarations
## Autoload singleton that holds all of the settings and variables as well as some signal receiver functions. 
##
## Due to the class [Log] being static, we require an autoload to hold all of the variables, settings and signals.[br]
## [color=red]WARNING: [br][color=white]When installing the plugin Gologger.tscn should be added as an autoload. Ensure that it's in [code]Project > Project Settings > Globals > Autoload[/code] and if it doesn't appear in the list. Add the "GoLogger.TSCN" scene file. NOT THE ".gd" file, or the plugin won't work.

signal toggle_session_status(status : bool) ## Emitted at the end of [code]Log.start_session()[/code] and [code]Log.end_session[/code]. This signal is responsible for turning sessions on and off.
signal session_status_changed ## Emitted when session status is changed. Use to signal your other scripts that the session is active. 
signal session_timer_started ## Emitted when the [param session_timer] is started. Useful for other applications that file size manage. E.g. when stress testing some system and logging is needed for a set time. Having a 'started' signal can be useful to initiate a test.
@export_enum("Project name & Project version", "Project name", "Project version", "None") var log_info_header : int = 0 ## Denotes the type of header used in the .log file header. I.e. the string that says:[br][i]"Project X version 0.84 - Game Log session started[2024-09-16 21:38:04]:
var header_string : String ## String result from [param log_info_header], that contains either project name, project version, both or none
@export var disable_errors : bool = true ## Enables/disables all debug warnings and errors
@export var hide_contoller_on_start : bool = false ## Hides GoLoggerController when running your project. Use F9(by default) to toggle visibility.
@export var controller_drag_offset : Vector2 = Vector2(-180, -60) ## Correcting offset for the controller while draggin(may require changing depending on your project resolution).
@export var autostart_session : bool = true ## Starts the session in the '_ready()' function of GoLogger.gd.
var session_status: bool = false ## Main session status bool. 
@export_enum("None", "Start & Stop Session", "Start Session only", "Stop Session only") var session_print : int = 0 ## Used to [method print] whenever a session is started or stopped to the Output. 
@export var include_log_name : bool = true ## includes the .log names that's logged into the print statements when using [param session_print].

@export_category("Log Management") 
@onready var session_timer: Timer = $SessionTimer ## Timer node that tracks the session time. Will stop and start new sessions on [signal timeout].
@export var file_cap = 3 ## Sets the max number of log files. Deletes the oldest log file in directory when file count exceeds this number.
## Denotes the method of log management used to prevent long and large .log files. Prevents potential performance issues(see "Preventing too large .log files" in the README for more info).[br]
## [b]1. Entry Limit:[/b] Checks the number of entries in the file when logging a new ones. If entry count exceeds [param entry_count_limit], the oldest entry in file is removed to make room for the new entry.[br]
## [b]2. Session Timer:[/b] Whenever a session is started, the [param session_timer] is started, counting down the [param session_timer_wait_time] value. Upon [signal timeout], the session is stopped and depending on the [param session_timeout_action]. It will either start a new session(creating a new .log file), stop the session only(requires manual restart) or clear the current log of it's contents and continue to log in the same file.[br]
## [b]3. Both Entry Count Limit and Session Timer:[/b] Uses both of the above methods.[br]
## [b]4. None:[/b] Uses no methods of preventing too large files. Not recommended, particularly so if you intend to ship your game with this plugin.
@export_enum("Entry Count Limit", "Session Timer", "Both Entry Limit & Session Timer", "None") var log_manage_method : int = 0
## The log entry count(or line count) limit allowed in the .log file. If entry count exceeds this number, the oldest entry is removed before adding the new.
## [b]Stop & start new session:[/b] Stops the current session and starting a new one. Creates a new .log file to continue log into.[br][b]Stop session only:[/b] Stops the current session without starting a new one. Note that this requires a manual restart which can be done in the Controller, or if you've implemented your own way of starting it.[br][b]Clear current log:[/b] Clears the current .log file of it's previous log entries and continues to log into the same file.
@export_enum("Stop & start new session", "Stop session only") var session_timeout_action : int = 0
@export var entry_count_limit: int = 100 ## The maximum number of log entries allowed in one file before it starts to delete the oldest entry when adding a new.
var entry_count_game : int = 0 ## The current count of entries in the game.log.
var entry_count_player : int = 0 ## The current count of entries in the player.log.
## Default length of time for a session when [param Session Timer] is enabled
@export var session_timer_wait_time : float = 120.0: 
	set(new):
		session_timer_wait_time = new
		if session_timer != null: session_timer.wait_time = session_timer_wait_time
var current_game_filepath : String = "" ## game.log file path associated with the current session
var current_game_file : String = "" ## game.log file path associated with the current session
var current_player_filepath : String = "" ## player.log file path associated with the current session
var current_player_file : String = "" ## player.log file path associated with the current session


#endregion


func _ready() -> void:
	toggle_session_status.connect(_on_toggle_session_status)
	match log_info_header:
		0: # Project name + version
			header_string = str(
				ProjectSettings.get_setting("application/config/name") + " " if ProjectSettings.get_setting("application/config/name") != null else "",
				ProjectSettings.get_setting("application/config/version") + " " if ProjectSettings.get_setting("application/config/version") != null else "")
		1: # Project name
			header_string = str(
				ProjectSettings.get_setting("application/config/name") + " " if ProjectSettings.get_setting("application/config/name") != null else "")
		2: # Project version
			header_string = str(
				ProjectSettings.get_setting("application/config/name") + " " if ProjectSettings.get_setting("application/config/name") != null else "")
		3: header_string = ""
	
	if autostart_session:
		Log.start_session()
	if session_timer == null: 
		session_timer = Timer.new()
		add_child(session_timer)
		session_timer.owner = self
		session_timer.set_name("SessionTimer")
	# Fix: By connecting the signal at end of [method _ready], "start_session()" is prevented from being called twice during param _ready().
	session_timer.timeout.connect(_on_session_timer_timeout)
	session_timer.one_shot = false
	session_timer.wait_time = session_timer_wait_time
	session_timer.autostart = false


## Signal receiver: Toggles the session status between true/false upon signal [signal GoLogger.toggle_session_status] emitting. 
func _on_toggle_session_status(status : bool) -> void:
	session_status = status
	if !status: 
		session_timer.stop()
	else:  # Prevent the creation of file on the same timestamp by adding a "cooldown" timer
		await get_tree().create_timer(1.0)
		session_timer.start(session_timer_wait_time)
		session_timer_started.emit()
	session_status_changed.emit()

## Signal receiver: Stops and possibly starts the session when [param session_timer]s [signal timeout] signal is emitted. 
func _on_session_timer_timeout() -> void:
	match log_manage_method:
		0: # Entry count limit
			pass
		1: # Session Timer
			if session_timeout_action == 0: # Stop & Start
				Log.stop_session()
				Log.start_session()
			else: # Stop only
				Log.stop_session()
		2: # Both Count limit + Session timer
			if session_timeout_action == 0: # Stop & Start
				Log.stop_session()
				Log.start_session()
			else: # Stop only
				Log.stop_session()
		3: # None
			pass
	session_timer.wait_time = session_timer_wait_time
