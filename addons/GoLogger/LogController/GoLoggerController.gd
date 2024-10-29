extends Panel 

#region Documentation and variable declaration
## An optional controller to help manage logging sessions along with some additional features and information.
##
## Instantiate it into your existing UI to use. 
## [b]Session Toggle[/b] can be used to manually stop and start sessions.[br]
## [b]Session Timer [ProgressBar][/b] tells you the time left for the active session. Uses[param session_time] of [Log] as the [param wait_time]. The default session time is 10 minutes.[br]
## [b]Print buttons[/b] will print the .log file created last. If a session is started, this is the file that's being logged into actively. If a session is stopped, the log of the last session is printed.

@onready var update_timer			: Timer = 			$InfoUpdateTimer ## Updates info displayed in the [GoLoggerController] every time it times out(every 0.5s by default]
@onready var drag_button			: Button = 			$DragButton ## Drag the controller while pressing this button

@onready var session_status_label	: RichTextLabel = 	$MarginContainer/VBoxContainer/SessionStatusPanel/SessionStatusLabel

@onready var start_btn 				: Button =			$MarginContainer/VBoxContainer/HBoxContainer/StartButton
@onready var stop_btn 				: Button =			$MarginContainer/VBoxContainer/HBoxContainer/StartButton
@onready var copy_btn 				: Button =			$MarginContainer/VBoxContainer/HBoxContainer/StartButton

@onready var session_timer_pgb		: ProgressBar = 	$MarginContainer/VBoxContainer/TimerPanel/SessionTimerPGB
@onready var timer_status_label		: RichTextLabel = 	$MarginContainer/VBoxContainer/TimerPanel/TimerLabelHBOX/TimerStatusLabel
@onready var timer_left_label		: RichTextLabel = 	$MarginContainer/VBoxContainer/TimerPanel/TimerLabelHBOX/TimerLeftLabel

@onready var tooltip 				: Panel = 			$MarginContainer/VBoxContainer/Tooltip
@onready var tooltp_label 			: RichTextLabel = 	$MarginContainer/VBoxContainer/Tooltip/MarginContainer/RichTextLabel
@onready var fileinfo_panel			: Panel = 			$FileInfoPanel
@onready var fileinfo_container 	: VBoxContainer	=	$FileInfoPanel/MarginContainer/ScrollContainer/FileInfoContainer ## Container LogFiles are instantiated into.
var fileinfo_scene := preload("res://addons/GoLogger/Resources/FileInfo.tscn")
var fileinfos : Array
var fileinfo_state : bool = false:
	set(value):
		fileinfo_state = value
		fileinfo_panel.visible = value
		if value:
				for i in range(Log.file.size()):
					var instance = fileinfo_scene.instantiate()
					fileinfo_container.add_child(instance)
					instance.left_label.text = str(
						Log.file[i].filename_prefix, ":[font_size=10]
File:

File count: 
Entry count: "
					)
					instance.right_label.text = str(
						"[right] [font_size=10]
", Log.file[i].current_file, "

", Log.file[i].file_count, "
", Log.file[i].entry_count)
					fileinfos.append(instance)

		else:
			if fileinfo_container.get_child_count() != 0:
				for i in fileinfo_container.get_children():
					if i is Panel and i.get_name().contains("FileInfo"):
						i.queue_free()



var tooltip_status : bool = false:
	set(value):
		tooltip_status = value

var is_dragging : bool = false
#endregion




func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and Log.hotkey_toggle_controller.shortcut.matches_event(event) and event.is_released():	
		visible = !visible
	if event is InputEventJoypadButton and Log.hotkey_toggle_controller.shortcut.matches_event(event) and event.is_released():
		visible = !visible
func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and is_dragging:
		position = Vector2(event.position.x + Log.controller_drag_offset.x, event.position.y + Log.controller_drag_offset.y)


func _ready() -> void:
	#region Signal connections
	drag_button.button_up.connect(_on_drag_button.bind(false))
	drag_button.button_down.connect(_on_drag_button.bind(true))
	Log.session_status_changed.connect(_on_session_status_changed)
	Log.session_timer_started.connect(_on_session_timer_started)
	update_timer.timeout.connect(_on_update_timer_timeout)

	start_btn.button_up.connect(_on_start_button_button_up)
	start_btn.mouse_entered.connect(_on_start_button_mouse_entered)
	start_btn.mouse_exited.connect(_on_start_button_mouse_exited)

	copy_btn.button_up.connect(_on_copy_button_button_up)
	copy_btn.mouse_entered.connect(_on_copy_button_mouse_entered)
	copy_btn.mouse_exited.connect(_on_copy_button_mouse_exited)

	stop_btn.button_up.connect(_on_stop_button_button_up)
	stop_btn.mouse_entered.connect(_on_stop_button_mouse_entered)
	stop_btn.mouse_exited.connect(_on_stop_button_mouse_exited)
	#endregion

	tooltip.visible = true
	tooltip.
	fileinfo_panel.visible = fileinfo_state

	if Log.hide_contoller_on_start: hide()
	else: show()
	await get_tree().process_frame
	session_timer_pgb.min_value = 0
	session_timer_pgb.max_value = Log.session_timer_wait_time
	session_timer_pgb.step = Log.session_timer_wait_time / Log.session_timer_wait_time 
	await get_tree().process_frame 
	Log.session_timer.timeout.connect(_on_session_timer_timeout)
	session_timer_pgb.modulate = Color.BLACK if Log.session_timer.is_stopped() else Color.FOREST_GREEN
	session_status_label.text = str("[center][font_size=18] Session status:
[center][color=green]ON") if Log.session_status else str("[center][font_size=18] Session status:
[center][color=red]OFF")
	$FileInfoPanel/MarginContainer/ScrollContainer/FileInfoContainer/RichTextLabel.text = str("Base directory:\n", Log.base_directory)






## Called when [signal session_status_changed] is emitted from [Log].
func _on_session_status_changed() -> void:
	session_status_label.text = str("[center][font_size=18] Session status:
[center][color=green]ON") if Log.session_status else str("[center][font_size=18] Session status:
[center][color=red]OFF")


## Starts value time to update [ProgressBar] when session timer is started.
func _on_session_timer_started() -> void:
	update_timer.start()
	session_timer_pgb.modulate = Color.FOREST_GREEN
## Updates [ProgressBar] modulate depending on session status.
func _on_session_timer_timeout() -> void:
	session_timer_pgb.modulate = Color.BLACK


## Updates all values on the controller every 0.5 by default. This can be changed with the [param session_timer_wait_time] in [GoLogger].
func _on_update_timer_timeout() -> void:
	session_timer_pgb.modulate = Color.BLACK if Log.session_timer.is_stopped() else Color.FOREST_GREEN
	session_status_label.text = str("[center][font_size=18] Session status:
[center][color=green]ON") if Log.session_status else str("[center][font_size=18] Session status:
[center][color=red]OFF")
	# Session timer
	session_timer_pgb.value = Log.session_timer.get_time_left() 
	timer_status_label.text = str("[center][font_size=12]Status: 
", "[color=red]OFF" if Log.session_timer.is_stopped() else "[color=green]ON")
	timer_left_label.text = str("[center][font_size=12]TimeLeft:
[color=light_blue]", snappedi(Log.session_timer.get_time_left(), 1) )


## Sets [param is_dragging] depending on the pressed state of the drag button.
func _on_drag_button(state : bool) -> void:
	is_dragging = state


func _on_print_button_up(button : Button) -> void:
	match button.get_name():
		"PrintGameLogButton": print(Log.get_file_contents(Log.game_path))
		"PrintPlayerLogButton": print(Log.get_file_contents(Log.player_path))



func _on_start_button_mouse_entered() -> void:
	tooltp_label.text = "[font_size=12]Start a new session"
	tooltip_status = true

func _on_start_button_mouse_exited() -> void:
	tooltp_label.text = ""
	tooltip_status = false

func _on_start_button_button_up() -> void:
	Log.start_session()





func _on_copy_button_mouse_entered() -> void:
	tooltp_label.text = "[font_size=12]Saves a copy of the active session"
	tooltip_status = true

func _on_copy_button_mouse_exited() -> void:
	tooltp_label.text = ""
	tooltip_status = false

func _on_copy_button_button_up() -> void:
	Log.save_copy()







func _on_stop_button_mouse_entered() -> void:
	tooltp_label.text = "[font_size=12]Stops the active session"
	tooltip_status = true

func _on_stop_button_mouse_exited() -> void:
	tooltp_label.text = ""
	tooltip_status = false

func _on_stop_button_button_up() -> void:
	Log.stop_session()


func _on_show_log_file_button_button_up() -> void:
	print(fileinfo_state)
	fileinfo_state = !fileinfo_state


