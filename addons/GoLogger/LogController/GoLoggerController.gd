extends Panel
class_name GoLoggerController

## A controller to manage logging sessions along with some additional features to make it easier to manage GoLogger during runtime.
##
## [b]Game and Player Session buttons[/b] are used to indicate whether or not a session is running. But they can also be used to start and stop a session manually.[br]
## [b]Session Timer [ProgressBar][/b] tells you the time left for the session if you have it enabled. You can use the button below to start it manually at runtime but it will use the [param session_time] of the GoLoggerController as the wait_time and not the [GoLogger]s [param session_time]. The default session time is 2 minutes.[br]
## [b]Print buttons[/b] will print the .log file created last. If a session is started, this is the file that's being logged into actively. If a session is stopped, the log of the last session is printed.

@onready var info_timer: Timer = $InfoUpdateTimer ## Updates info displayed in the [GoLoggerController] every time it times out(every 0.5s by default]

@onready var session_button: CheckButton = $MarginContainer/VBoxContainer/SessionButton
@onready var print_gamelog_button: Button = $MarginContainer/VBoxContainer/PrintButtonHBOX/PrintGameLogButton 
@onready var print_playerlog_button: Button = $MarginContainer/VBoxContainer/PrintButtonHBOX/PrintPlayerLogButton 

@onready var character_title_label: RichTextLabel = $MarginContainer/VBoxContainer/Panel/MarginContainer/VBoxContainer/CharacterTitleLabel  
@onready var game_count_label: RichTextLabel = $MarginContainer/VBoxContainer/Panel/MarginContainer/VBoxContainer/CharCountLabelHBXC/GameCountLabel  
@onready var player_count_label: RichTextLabel = $MarginContainer/VBoxContainer/Panel/MarginContainer/VBoxContainer/CharCountLabelHBXC/PlayerCountLabel  

@onready var session_timer_pgb: ProgressBar = $MarginContainer/VBoxContainer/TimerPanel/SessionTimerPGB
@onready var timer_status_label: RichTextLabel = $MarginContainer/VBoxContainer/TimerPanel/TimerLabelHBOX/TimerStatusLabel
@onready var timer_left_label: RichTextLabel = $MarginContainer/VBoxContainer/TimerPanel/TimerLabelHBOX/TimerLeftLabel

# TODO: Add a "get_viewport_width() and height and add an export enum to say "position"

@export var session_time : float = 120.0:
	set(new):
		await get_tree().process_frame
		session_time = new
		GoLogger.session_time = session_time

func _input(event: InputEvent) -> void:
	if InputMap.has_action("gologger_controller_toggle"):
		if event.is_action_released("gologger_controller_toggle"):
			if visible: hide()
			else: show()

func _ready() -> void:
	#region Signal connections
	GoLogger.session_status_changed.connect(_on_session_status_changed)
	session_button.toggled.connect(_on_session_button_toggled) 
	print_gamelog_button.button_up.connect(_on_print_button_up.bind(print_gamelog_button))
	print_playerlog_button.button_up.connect(_on_print_button_up.bind(print_playerlog_button))
	GoLogger.session_timer_started.connect(_on_session_timer_started)
	info_timer.timeout.connect(_on_info_timer_timeout)
	#endregion
	
	await get_tree().process_frame
	session_timer_pgb.min_value = 0
	session_timer_pgb.max_value = GoLogger.session_timer_wait_time
	session_timer_pgb.step = GoLogger.session_timer_wait_time / GoLogger.session_timer_wait_time 
	await get_tree().process_frame # GoLogger autoload is initialized after this node -> Thus, await one physics frame
	GoLogger.session_timer.timeout.connect(_on_session_timer_timeout)
	session_timer_pgb.modulate = Color.BLACK if GoLogger.session_timer.is_stopped() else Color.FOREST_GREEN
	character_title_label.text = str("[center][font_size=14]Character Counts:
[font_size=12]Current Limit: [color=green]", GoLogger.session_character_limit)
	game_count_label.text = str("[center][font_size=12] GameLog:
", GoLogger.current_game_char_count)
	player_count_label.text = str("[center][font_size=12] PlayerLog:
1000", GoLogger.current_player_char_count)


## Signal receiver when Game Session CheckButton is toggled.
func _on_session_button_toggled(toggled_on : bool) -> void:  
	Log.stop_session() if !toggled_on else Log.start_session()
	# Prevent the creation of file on the same timestamp
	printerr("1", session_button.disabled)
	session_button.disabled = true
	await get_tree().create_timer(1.2).timeout
	printerr("2", session_button.disabled)
	session_button.disabled = false
	printerr("3", session_button.disabled)
	

## Received signal from [GoLogger] when session status is changed. 
func _on_session_status_changed() -> void:
	session_button.button_pressed = GoLogger.session_status


## Starts value time to update [ProgressBar] when session timer is started.
func _on_session_timer_started() -> void:
	info_timer.start()
	session_timer_pgb.modulate = Color.FOREST_GREEN
## Updates [ProgressBar] modulate depending on session status.
func _on_session_timer_timeout() -> void:
	session_timer_pgb.modulate = Color.BLACK


## Updates both the [ProgressBar] value and the last known character count on timeout.
func _on_info_timer_timeout() -> void:
	# Character count
	if GoLogger.current_game_char_count > GoLogger.session_character_limit or GoLogger.current_player_char_count > GoLogger.session_character_limit:
		character_title_label.text = str("[center][font_size=14]Character Counts:
[font_size=12]Current Limit: [color=red]", GoLogger.session_character_limit)
	else: character_title_label.text = str("[center][font_size=14]Character Counts:
[font_size=12]Current Limit: [color=green]", GoLogger.session_character_limit)
	game_count_label.text = str("[center][font_size=12] GameLog:
1000", GoLogger.current_game_char_count)
	player_count_label.text = str("[center][font_size=12] PlayerLog:
1000", GoLogger.current_game_char_count)
	
	# Session timer
	session_timer_pgb.value = GoLogger.session_timer.get_time_left() 
	timer_status_label.text = str("[center][font_size=12]Status: 
", "[color=red]OFF" if GoLogger.session_timer.is_stopped() else "[color=green]ON")
	timer_left_label.text = str("[center][font_size=12]TimeLeft:
[color=light_blue]", snappedi(GoLogger.session_timer.get_time_left(), 1) )


## Prints the current/latest log contents to 'Output'.
func _on_print_button_up(button : Button) -> void:
	match button.get_name():
		"PrintGameLogButton": print(Log.get_file_contents(Log.GAME_PATH))
		"PrintPlayerLogButton": print(Log.get_file_contents(Log.PLAYER_PATH))
