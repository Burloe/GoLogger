extends Panel
class_name GoLoggerController

## A controller to manage logging sessions along with some additional features to make it easier to manage GoLogger during runtime.
##
## [b]Game and Player Session buttons[/b] are used to indicate whether or not a session is running. But they can also be used to start and stop a session manually.[br]
## [b]Session Timer [ProgressBar][/b] tells you the time left for the session if you have it enabled. You can use the button below to start it manually at runtime but it will use the [param session_time] of the GoLoggerController as the wait_time and not the [GoLogger]s [param session_time]. The default session time is 2 minutes.[br]
## [b]Print buttons[/b] will print the .log file created last. If a session is started, this is the file that's being logged into actively. If a session is stopped, the log of the last session is printed.

@onready var game_button: CheckButton = $MarginContainer/VBoxContainer/GameButton
@onready var player_button: CheckButton = $MarginContainer/VBoxContainer/PlayerButton
@onready var print_gamebutton: Button = $MarginContainer/VBoxContainer/HBoxContainer2/PrintGameLogButton
@onready var print_playerbutton: Button = $MarginContainer/VBoxContainer/HBoxContainer2/PrintPlayerLogButton
@onready var session_timer_pgb: ProgressBar = $MarginContainer/VBoxContainer/SessionTimerPGB
@onready var value_timer: Timer = $MarginContainer/VBoxContainer/SessionTimerPGB/ValueTimer
@onready var char_title_label: RichTextLabel = $MarginContainer/VBoxContainer/CharacterTitleLabel
@onready var char_count_game_label: RichTextLabel = $MarginContainer/VBoxContainer/CharCountLabelHBXC/GameCountLabel
@onready var char_count_player_label: RichTextLabel = $MarginContainer/VBoxContainer/CharCountLabelHBXC/PlayerCountLabel

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
	game_button.toggled.connect(_on_gamesession_button_toggled)
	player_button.toggled.connect(_on_playersession_button_toggled)
	print_gamebutton.button_up.connect(_on_print_button_up.bind(print_gamebutton))
	print_playerbutton.button_up.connect(_on_print_button_up.bind(print_playerbutton))
	GoLogger.session_timer_started.connect(_on_session_timer_started)
	value_timer.timeout.connect(_on_value_timer_timeout)
	#endregion
	
	await get_tree().process_frame
	session_timer_pgb.min_value = 0
	session_timer_pgb.max_value = GoLogger.session_timer_wait_time
	session_timer_pgb.step = GoLogger.session_timer_wait_time / GoLogger.session_timer_wait_time 
	await get_tree().process_frame # GoLogger autoload is initialized after this node -> Thus, await one physics frame
	GoLogger.session_timer.timeout.connect(_on_session_timer_timeout)
	session_timer_pgb.modulate = Color.BLACK if GoLogger.session_timer.is_stopped() else Color.FOREST_GREEN
	char_title_label.text = str("[center][font_size=14]Character Counts:
[font_size=12]Current Limit: [color=green]", GoLogger.session_character_limit)
	char_count_game_label.text = str("[center][font_size=12] GameLog:
", GoLogger.current_game_char_count)
	char_count_player_label.text = str("[center][font_size=12] PlayerLog:
1000", GoLogger.current_player_char_count)


## Signal receiver when Game Session CheckButton is toggled.
func _on_gamesession_button_toggled(toggled_on : bool) -> void:  
	GoLogger.toggle_session_status.emit(0, toggled_on)
	
## Signal receiver when Player Session CheckButton is toggled.
func _on_playersession_button_toggled(toggled_on : bool) -> void: 
	GoLogger.toggle_session_status.emit(1, toggled_on)

## Received signal from [GoLogger] when session status is changed. 
func _on_session_status_changed() -> void:
	game_button.button_pressed = GoLogger.game_session_status
	player_button.button_pressed = GoLogger.player_session_status

## Starts value time to update [ProgressBar] when session timer is started.
func _on_session_timer_started() -> void:
	value_timer.start()
	session_timer_pgb.modulate = Color.FOREST_GREEN

## Updates [ProgressBar] modulate depending on session status.
func _on_session_timer_timeout() -> void:
	session_timer_pgb.modulate = Color.BLACK

## Updates both the [ProgressBar] value and the last known character count on timeout.
func _on_value_timer_timeout() -> void:
	session_timer_pgb.value = GoLogger.session_timer.get_time_left() 
	char_title_label.text = str("[center][font_size=14]Character Counts:
[font_size=12]Current Limit: [color=green]", GoLogger.session_character_limit)
	char_count_game_label.text = str("[center][font_size=12] GameLog:
", GoLogger.current_game_char_count)
	char_count_player_label.text = str("[center][font_size=12] PlayerLog:
1000", GoLogger.current_player_char_count)

## Prints the current/latest log contents to 'Output'.
func _on_print_button_up(button : Button) -> void:
	match button.get_name():
		"PrintGameLogButton": print(Log.get_file_contents(Log.GAME_PATH))
		"PrintPlayerLogButton": print(Log.get_file_contents(Log.PLAYER_PATH))
