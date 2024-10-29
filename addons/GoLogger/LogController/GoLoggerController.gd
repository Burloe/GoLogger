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

@onready var session_status_label	: RichTextLabel = 	$MarginContainer/VBoxContainer/SessionStatusPanel/SessionStatusLabel		## Session status button

@onready var start_btn 				: Button =			$MarginContainer/VBoxContainer/HBoxContainer/StartButton					## Start session button
@onready var copy_btn 				: Button =			$MarginContainer/VBoxContainer/HBoxContainer/CopyButton						## Copy session button
@onready var stop_btn 				: Button =			$MarginContainer/VBoxContainer/HBoxContainer/StopButton						## Stop session button

@onready var session_timer_pgb		: ProgressBar = 	$MarginContainer/VBoxContainer/TimerPanel/SessionTimerPGB					## Session timer progressbar
@onready var timer_status_label		: RichTextLabel = 	$MarginContainer/VBoxContainer/TimerPanel/TimerLabelHBOX/TimerStatusLabel	## Timer status label
@onready var timer_left_label		: RichTextLabel = 	$MarginContainer/VBoxContainer/TimerPanel/TimerLabelHBOX/TimerLeftLabel		## Timer left label

@onready var tooltip 				: Panel = 			$MarginContainer/VBoxContainer/Tooltip										## Tooltip root node
@onready var tooltip_label 			: RichTextLabel = 	$MarginContainer/VBoxContainer/Tooltip/MarginContainer/RichTextLabel		## Tooltip Label

@onready var fileinfo_panel			: Panel = 			$FileInfoPanel 																## FileInfo root node
@onready var fileinfo_container 	: VBoxContainer	=	$FileInfoPanel/MarginContainer/ScrollContainer/FileInfoContainer 			## Container LogFiles are instantiated into.
@onready var fileinfo_button 		: Button = 			$MarginContainer/VBoxContainer/ShowLogFileButton 							## FileInfo toggle button
@onready var fileinfo_side_button 	: Button = 			$FileInfoPanel/FileInfoSide_Button											## Positional toggle button for FileInfo panel
var fileinfo_side : bool = true: ## false = left - right = true
	set(value):
		fileinfo_side = value
		fileinfo_panel.position = Vector2(213, 0) if value else Vector2(-273, 0)

var fileinfo_scene := preload("res://addons/GoLogger/Resources/FileInfo.tscn")
var fileinfos : Array
var fileinfo_state : bool = false:
	set(value):
		fileinfo_state = value
		fileinfo_panel.visible = value
		if value:
				for i in range(Log.categories.size()):
					var instance = fileinfo_scene.instantiate()
					fileinfo_container.add_child(instance)
					instance.name_label.text = str("[center]", Log.categories[i].category_name)
					instance.left_label.text = str("[font_size=10]File:\n\nFile count:\nEntry count:")
					instance.right_label.text = str("[right][font_size=10]", Log.categories[i].current_file, "\n\n", Log.categories[i].file_count -1, "\n", Log.categories[i].entry_count)
# 					instance.right_label.text = str(
# 						"[right] [font_size=10]
# ", Log.categories[i].current_file, "

# ", Log.categories[i].file_count -1, "
# ", Log.categories[i].entry_count)
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

	fileinfo_button.button_up.connect(_on_fileinfo_button_up)
	fileinfo_button.mouse_entered.connect(_on_fileinfo_mouse_entered)
	fileinfo_button.mouse_exited.connect(_on_fileinfo_mouse_exited)

	fileinfo_side_button.button_up.connect(_on_fileinfo_side_button_up)
	fileinfo_side_button.mouse_entered.connect(_on_fileinfo_pos_mouse_entered)
	fileinfo_side_button.mouse_exited.connect(_on_fileinfo_pos_mouse_exited)
	#endregion

	tooltip.visible = true
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
	session_status_label.text = str("[center][font_size=18] Session status:\n[center][color=green]ON") if Log.session_status else str("[center][font_size=18] Session status:\n[center][color=red]OFF")





#region Signal listeners
## Called when [signal session_status_changed] is emitted from [Log].
func _on_session_status_changed() -> void:
	session_status_label.text = str("[center][font_size=18] Session status:\n[center][color=green]ON") if Log.session_status else str("[center][font_size=18] Session status:\n[center][color=red]OFF")


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
	session_status_label.text = str("[center][font_size=18] Session status:\n[center][color=green]ON") if Log.session_status else str("[center][font_size=18] Session status:\n[center][color=red]OFF")
	# Session timer
	session_timer_pgb.value = Log.session_timer.get_time_left() 
	timer_status_label.text = str("[center][font_size=12]Status:\n[color=red]OFF" if Log.session_timer.is_stopped() else "[color=green]ON")
	timer_left_label.text = str("[center][font_size=12]TimeLeft:\n[color=light_blue]", snappedi(Log.session_timer.get_time_left(), 1) )


## Sets [param is_dragging] depending on the pressed state of the drag button.
func _on_drag_button(state : bool) -> void:
	is_dragging = state




func _on_start_button_mouse_entered() -> void: 
	tooltip_label.text = "[font_size=12]Start a new session"
	tooltip_status = true

func _on_start_button_mouse_exited() -> void: 
	tooltip_label.text = ""
	tooltip_status = false

func _on_start_button_button_up() -> void:
	Log.start_session()



func _on_copy_button_mouse_entered() -> void: 
	tooltip_label.text = "[font_size=12]Saves a copy of the active session into a separate logs."
	tooltip_status = true

func _on_copy_button_mouse_exited() -> void: 
	tooltip_label.text = ""
	tooltip_status = false

func _on_copy_button_button_up() -> void:
	Log.save_copy()



func _on_stop_button_mouse_entered() -> void: 
	tooltip_label.text = "[font_size=12]Stops the active session."
	tooltip_status = true

func _on_stop_button_mouse_exited() -> void: 
	tooltip_label.text = ""
	tooltip_status = false

func _on_stop_button_button_up() -> void:
	Log.stop_session()



func _on_fileinfo_button_up() -> void:
	fileinfo_state = !fileinfo_state

func _on_fileinfo_mouse_entered() -> void:
	tooltip_label.text = "[font_size=12]Toggle log category information.\n[i]Not accessible without active session or without log categories."

func _on_fileinfo_mouse_exited() -> void:
	tooltip_label.text = ""



func _on_fileinfo_side_button_up() -> void:
	fileinfo_side = !fileinfo_side
	

func _on_fileinfo_pos_mouse_entered() -> void:
	tooltip_label.text = "[font_size=12]Move panel to left" if fileinfo_side else "[font_size=12]Move panel to right"
	fileinfo_side_button.text = "Move to left side" if fileinfo_side else "Move to right side"

func _on_fileinfo_pos_mouse_exited() -> void:
	tooltip_label.text = ""
	fileinfo_side_button.text = ""
#endregion