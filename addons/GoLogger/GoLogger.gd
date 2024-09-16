@icon("res://addons/GoLogger/GoLogger.png")
extends Node
#TODO: toggle the controller on or off
## Responsible for most non-static operations. Make sure that the GoLogger.tscn file is an autoload before using GoLogger. Note that it's the .TSCN we want to be an autoload and not the script file.
##
## The plugin has two safeguard in place in order to prevent potential issues. A character count is performed each time anything is written to the log and a session timer also starts alongside a session. These are turned off by default but does still count the characters and start/stop the timer. Having them enabled/disabled merely determines whether or not it will perform a behaviour once their conditions are fulfilled.[br][br]
## [color=red]WARNING: [br][color=white]When installing the plugin Gologger.tscn should be added as an autoload. Ensure that it's in [code]Project > Project Settings > Globals > Autoload[/code] and if it doesn't appear in the list. Add the "GoLogger.TSCN" scene file. NOT THE ".gd" file, or the plugin won't work.

## Emitted at the end of [code]Log.start_session()[/code] and [code]Log.end_session[/code]. This signal is responsible for turning sessions on and off.
signal toggle_session_status(status : bool) 
signal session_status_changed ## Emitted when session status is changed. 
signal session_timer_started ## Emitted when the [param session_timer] is started.
@export var disable_welcome_message : bool = false ## Disables the GoLogger welcome message. You can also go into the "plugin.gd" and comment out the message to completely remove it.
@export var debug_warnings_errors : bool = true ## Enables/disables all debug prints, warnings and errors
@export var autostart_logs : bool = true ## Sessions will autostart when running your project.
@export var file_cap = 3 ## Sets the max number of log files. Deletes the oldest log file in directory when file count exceeds this number.
@export var session_status: bool = false ## Flags whether a log session is in progress or not, only meant to be a visual hint to see if the session is started or not. [br][b]NOT RECOMMENDED TO BE USED TO START AND RESTART SESSIONS![/b]

@export_group("Session Limit & Timer")
@export var session_timer: Timer ## Timer node that tracks the session time. Will stop and start new sessions on [signal timeout].
## Denotes the condition which trigger(s) stop a session. This is to prevent possible performance issues when adding entries to logs. See README/GitHub, section "Potential Performance Issues" for more information.[br][br]
## [b]None:[/b] No automatic session managing. Logging session will continue until manually stopped or until your game is stopped.[br]
## [b]Character Limit:[/b] Session is stopped when the character count exceeds the [param session_character_limit].[br]
## [b]Session Timer:[/b] a [Timer] is started whenever a session is, and when [signal timeout] is emitted. The session is stopped.[br]
## [i]Note:[br]    This only determines the condition and should be used in tandem with [param end_session_behavior] to decide what happens once the condition is fulfilled. 
@export_enum("None", "Character Limit", "Session Timer", "Limit + Timer") var end_session_condition : int = 0

## Determines the behavior once the [param end_session_condition] is triggered. This is to prevent possible performance issues when adding entries to logs. See README/GitHub, section "Potential Performance Issues " for more information.[br][br]
## [b]Stop & Start new session:[/b] Stops the session and immidietly starts a new one, logging into a newly generated file.[br]
## [b]Stop session only:[/b] Stops the current session but doesn't start a new one. Effectively stopping logging until manually started again(or if you've built your own custom [code]start_session()[/code] trigger).[br]
## [b]Clear Log(destructive):[/b] Doesn't stop the current session and instead purges the .log contents and continues to log on the same session and .log file. 
@export_enum("Stop + Start new session", "Stop session only", "Clear log") var end_session_behavior : int = 0

## Character limit used if [param end_session_condition] is set to "Character Limit" or "Both Limit + Timer".
@export var session_character_limit : int = 10000
## Sets enables autostanrt of session [Timer].
@export var session_timer_autostart : bool = false
## Default length of time for a session when [param Session Timer] is enabled
@export var session_timer_wait_time : float = 120.0:
	set(new):
		session_timer_wait_time = new
		if session_timer != null: session_timer.wait_time = session_timer_wait_time
@onready var current_game_char_count : int = 0 ## Current character count in the game.log.
@onready var current_player_char_count : int = 0 ## Current character count in the player.log.
var current_game_file : String = "" ## .log file associated with the current session
var current_player_file : String = "" ## .log file associated with the current session



func _ready() -> void:
	toggle_session_status.connect(_on_toggle_session_status)
	if autostart_logs:
		toggle_session_status.emit(true)
	if session_timer == null:
		session_timer = Timer.new()
		add_child(session_timer)
		session_timer.owner = self
		session_timer.set_name("SessionTimer")
	session_timer.timeout.connect(_on_session_timer_timeout)
	session_timer.one_shot = false
	session_timer.wait_time = session_timer_wait_time
	session_timer.autostart = true


## Toggles the session status between true/false upon signal [signal GoLogger.toggle_session_status] emitting. 
func _on_toggle_session_status(status : bool) -> void:
	printerr("toggle session status received = ", status)
	session_status = status
	if !status: 
		session_timer.stop()
	else:  
		# Prevent the creation of file on the same timestamp
		await get_tree().create_timer(1.0)
		session_timer.start(session_timer_wait_time)
		session_timer_started.emit()
	session_status_changed.emit()


func _on_session_timer_timeout() -> void:
	if end_session_condition >= 2:
		Log.stop_session() 
		if end_session_behavior != 1:
			Log.start_session() 
	session_timer.wait_time = session_timer_wait_time
