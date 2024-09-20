extends Panel
class_name GoLoggerController

#region Documentation and variable declaration
## A controller to manage logging sessions along with some additional features to make it easier to manage GoLogger during runtime.
##
## [b]Game and Player Session buttons[/b] are used to indicate whether or not a session is running. But they can also be used to start and stop a session manually.[br]
## [b]Session Timer [ProgressBar][/b] tells you the time left for the session if you have it enabled. You can use the button below to start it manually at runtime but it will use the [param session_time] of the GoLoggerController as the wait_time and not the [GoLogger]s [param session_time]. The default session time is 2 minutes.[br]
## [b]Print buttons[/b] will print the .log file created last. If a session is started, this is the file that's being logged into actively. If a session is stopped, the log of the last session is printed.

@onready var update_timer: Timer = $InfoUpdateTimer ## Updates info displayed in the [GoLoggerController] every time it times out(every 0.5s by default]
@onready var drag_button: Button = $DragButton ## Drag the controller while pressing this button

@onready var session_status_label: RichTextLabel = $MarginContainer/VBoxContainer/SessionStatusPanel/SessionStatusLabel
@onready var session_button: CheckButton = $MarginContainer/VBoxContainer/SessionButton
@onready var print_gamelog_button: Button = $MarginContainer/VBoxContainer/PrintButtonHBOX/PrintGameLogButton 
@onready var print_playerlog_button: Button = $MarginContainer/VBoxContainer/PrintButtonHBOX/PrintPlayerLogButton 

@onready var entry_title_label: RichTextLabel = $MarginContainer/VBoxContainer/Panel/MarginContainer/VBoxContainer/EntryCountTitleLabel
@onready var game_count_label: RichTextLabel =  $MarginContainer/VBoxContainer/Panel/MarginContainer/VBoxContainer/EntryCountLabelHBXC/GameCountLabel
@onready var player_count_label: RichTextLabel = $MarginContainer/VBoxContainer/Panel/MarginContainer/VBoxContainer/EntryCountLabelHBXC/PlayerCountLabel

@onready var session_timer_pgb: ProgressBar = $MarginContainer/VBoxContainer/TimerPanel/SessionTimerPGB
@onready var timer_status_label: RichTextLabel = $MarginContainer/VBoxContainer/TimerPanel/TimerLabelHBOX/TimerStatusLabel
@onready var timer_left_label: RichTextLabel = $MarginContainer/VBoxContainer/TimerPanel/TimerLabelHBOX/TimerLeftLabel

var is_dragging : bool = false
#endregion

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.keycode == KEY_F9: # Change keybind to toggle controller here
		if event.is_released():
			if visible: hide()
			else: show()
	
	if event is InputEventMouseMotion:
		if is_dragging:
			position = Vector2(event.position.x + GoLogger.controller_drag_offset.x, event.position.y + GoLogger.controller_drag_offset.y)

func _ready() -> void:
	#region Signal connections
	drag_button.button_up.connect(_on_drag_button.bind(false))
	drag_button.button_down.connect(_on_drag_button.bind(true))
	GoLogger.session_status_changed.connect(_on_session_status_changed)
	if !GoLogger.autostart_session: session_button.toggled.connect(_on_session_button_toggled) 
	print_gamelog_button.button_up.connect(_on_print_button_up.bind(print_gamelog_button))
	print_playerlog_button.button_up.connect(_on_print_button_up.bind(print_playerlog_button))
	GoLogger.session_timer_started.connect(_on_session_timer_started)
	update_timer.timeout.connect(_on_update_timer_timeout)
	#endregion
	
#region Apply base values and settings
	hide() if GoLogger.hide_contoller_on_start else show()
	await get_tree().process_frame
	session_timer_pgb.min_value = 0
	session_timer_pgb.max_value = GoLogger.session_timer_wait_time
	session_timer_pgb.step = GoLogger.session_timer_wait_time / GoLogger.session_timer_wait_time 
	# GoLogger autoload is initialized after this node -> Thus, await one physics frame. Can also use the "ready" signal.
	await get_tree().process_frame 
	GoLogger.session_timer.timeout.connect(_on_session_timer_timeout)
	session_timer_pgb.modulate = Color.BLACK if GoLogger.session_timer.is_stopped() else Color.FOREST_GREEN
	entry_title_label.text = str("[center][font_size=14]Log Entry Count:
[font_size=12]Current Limit: [color=green]", GoLogger.entry_count_limit)
	game_count_label.text = str("[center][font_size=12] GameLog:
", GoLogger.entry_count_game)
	player_count_label.text = str("[center][font_size=12] PlayerLog:
", GoLogger.entry_count_player)
#endregion




## Signal receiver when Game Session CheckButton is toggled.
func _on_session_button_toggled(toggled_on : bool) -> void:
	Log.stop_session() if !toggled_on else Log.start_session() 
	# Prevent the creation of conflicting file names with the same timestamp, resulting in additional numbers which caused issues in my testing.
	session_button.disabled = true
	await get_tree().create_timer(1.2).timeout 
	session_button.disabled = false 


## Received signal from [GoLogger] when session status is changed. 
func _on_session_status_changed() -> void:
	session_button.button_pressed = GoLogger.session_status
	session_status_label.text = str("[center][font_size=18] Session status:
[center][color=green]ON") if GoLogger.session_status else str("[center][font_size=18] Session status:
			[center][color=red]OFF")
	# Connect signal after setting the initial state(if autostart is on)
	if !session_button.toggled.is_connected(_on_session_button_toggled): 
		session_button.toggled.connect(_on_session_button_toggled)


## Signal receiver: Starts value time to update [ProgressBar] when session timer is started.
func _on_session_timer_started() -> void:
	update_timer.start()
	session_timer_pgb.modulate = Color.FOREST_GREEN
## Signal receiver: Updates [ProgressBar] modulate depending on session status.
func _on_session_timer_timeout() -> void:
	session_timer_pgb.modulate = Color.BLACK


## Signal receiver: Updates all values on the controller every 0.5 by default. This can be changed with the [param session_timer_wait_time] in [GoLogger].
func _on_update_timer_timeout() -> void:
	session_timer_pgb.modulate = Color.BLACK if GoLogger.session_timer.is_stopped() else Color.FOREST_GREEN
	session_status_label.text = str("[center][font_size=18] Session status:
[center][color=green]ON") if GoLogger.session_status else str("[center][font_size=18] Session status:
[center][color=red]OFF")
	# Entry count logic
	if GoLogger.entry_count_game > GoLogger.entry_count_limit or GoLogger.entry_count_player > GoLogger.entry_count_limit:
		entry_title_label.text = str("[center][font_size=14]Log Entry Count:
[font_size=12]Current Limit: [color=red]", GoLogger.entry_count_limit)
	else: entry_title_label.text = str("[center][font_size=14]Log Entry Count:
[font_size=12]Current Limit: [color=green]", GoLogger.entry_count_limit)
	game_count_label.text = str("[center][font_size=12] GameLog:
", GoLogger.entry_count_game)
	player_count_label.text = str("[center][font_size=12] PlayerLog:
", GoLogger.entry_count_player)
	# Session timer
	session_timer_pgb.value = GoLogger.session_timer.get_time_left() 
	timer_status_label.text = str("[center][font_size=12]Status: 
", "[color=red]OFF" if GoLogger.session_timer.is_stopped() else "[color=green]ON")
	timer_left_label.text = str("[center][font_size=12]TimeLeft:
[color=light_blue]", snappedi(GoLogger.session_timer.get_time_left(), 1) )


## Signal receiver: Prints the current/latest log contents to 'Output'.
func _on_print_button_up(button : Button) -> void:
	match button.get_name():
		"PrintGameLogButton": print(Log.get_file_contents(Log.GAME_PATH))
		"PrintPlayerLogButton": print(Log.get_file_contents(Log.PLAYER_PATH))


## Sets [param is_dragging] depending on the pressed state of the drag button.
func _on_drag_button(state : bool) -> void:
	is_dragging = state
