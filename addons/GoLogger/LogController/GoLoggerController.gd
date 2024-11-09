extends Panel 

#region Documentation and declarations
## An optional controller to help manage logging sessions along with some additional features and information.


## Drag the controller while pressing this button.
@onready var drag_button : Button = $DragButton
## Session status button.
@onready var session_status_label : RichTextLabel = $MarginContainer/VBoxContainer/SessionStatusPanel/SessionStatusLabel


## Start session button.
@onready var start_btn : Button = $MarginContainer/VBoxContainer/HBoxContainer/StartButton

## Copy session button.
@onready var copy_btn : Button = $MarginContainer/VBoxContainer/HBoxContainer/CopyButton

## Stop session button.
@onready var stop_btn : Button = $MarginContainer/VBoxContainer/HBoxContainer/StopButton


## Session timer progressbar.
@onready var session_timer_pgb : ProgressBar = $MarginContainer/VBoxContainer/TimerPanel/SessionTimerPGB

## Timer status label.
@onready var timer_status_label : RichTextLabel = $MarginContainer/VBoxContainer/TimerPanel/TimerLabelHBOX/TimerStatusLabel

## Timer left label.
@onready var timer_left_label : RichTextLabel = $MarginContainer/VBoxContainer/TimerPanel/TimerLabelHBOX/TimerLeftLabel

## Tooltip root node.
@onready var tooltip : Panel = $MarginContainer/VBoxContainer/Tooltip

## Tooltip Label.
@onready var tooltip_label : RichTextLabel = $MarginContainer/VBoxContainer/Tooltip/MarginContainer/RichTextLabel


## FileInfo root node.
@onready var fileinfo_panel : Panel = $FileInfoPanel

## Container LogFiles are instantiated into.
@onready var fileinfo_container : VBoxContainer	= $FileInfoPanel/MarginContainer/ScrollContainer/FileInfoContainer

## FileInfo toggle button.
@onready var fileinfo_button : Button = $MarginContainer/VBoxContainer/ShowLogFileButton

## Positional toggle button for FileInfo panel.
@onready var fileinfo_side_button : Button = $FileInfoPanel/FileInfoSide_Button

## Flags whether or not the controller is dragged 
var is_dragging : bool = false 

## Shifts side of file info panel. false = left - right = true
var fileinfo_side : bool = true: 																									
	set(value):
		fileinfo_side = value
		fileinfo_panel.position = Vector2(213, 0) if value else Vector2(-273, 0)

## Gets instantiated depending on the number of file categories.
var fileinfo_scene := preload("res://addons/GoLogger/Resources/FileInfo.tscn")
## Array containing each instance.
var fileinfos : Array
## State whether or not the file info panel is shown or not.
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
					fileinfos.append(instance)
		else:
			if fileinfo_container.get_child_count() != 0:
				for i in fileinfo_container.get_children():
					if i is Panel and i.get_name().contains("FileInfo"):
						i.queue_free()

const PATH = "user://GoLogger/settings.ini"
var config = ConfigFile.new()
#endregion




func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and Log.hotkey_toggle_controller.shortcut.matches_event(event) and event.is_released():	
		visible = !visible
	if event is InputEventJoypadButton and Log.hotkey_toggle_controller.shortcut.matches_event(event) and event.is_released():
		visible = !visible

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and is_dragging:
		position = Vector2(Vector2(get_value("drag_offset_x"), get_value("drag_offset_y")))


func _ready() -> void:
	#region Signal connections
	drag_button.button_up.connect(_on_drag_button.bind(false))
	drag_button.button_down.connect(_on_drag_button.bind(true))
	Log.session_status_changed.connect(_on_session_status_changed)
	Log.session_timer_started.connect(_on_session_timer_started)

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
	set_position(Vector2(get_value("controller_xpos"), get_value("controller_ypos")))
	tooltip.visible = get_value("show_controller")
	fileinfo_side = get_value("controller_monitor_side")
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


## Returns any setting value from 'settings.ini'. Also preforms some crucial error checks, pushes errors and creates 
## a default .ini file if one doesn't exist.
func get_value(value : String) -> Variant:
	var _config = ConfigFile.new()
	var _result = _config.load(PATH) 
	
	if !FileAccess.file_exists(PATH):
		push_warning(str("GoLogger Warning: No settings.ini file present in ", PATH, ". Generating a new file with default settings."))
	
	if _result != OK:
		push_error(str("GoLogger Error: ConfigFile failed to load settings.ini file."))
		return null
	
	var _val = _config.get_value("settings", value)
	if _val == null:
		push_error(str("GoLogger Error: ConfigFile failed to load settings value from file."))
	return _val




#region Signal listeners
## Called when [signal session_status_changed] is emitted from [Log].
func _on_session_status_changed() -> void:
	session_status_label.text = str("[center][font_size=18] Session status:\n[center][color=green]ON") if Log.session_status else str("[center][font_size=18] Session status:\n[center][color=red]OFF")


## Starts value time to update [ProgressBar] when session timer is started.
func _on_session_timer_started() -> void:
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

func _on_start_button_mouse_exited() -> void: 
	tooltip_label.text = "" 

func _on_start_button_button_up() -> void:
	Log.start_session()


func _on_copy_button_mouse_entered() -> void: 
	tooltip_label.text = "[font_size=12]Saves a copy of the active session into a separate logs."

func _on_copy_button_mouse_exited() -> void: 
	tooltip_label.text = ""

func _on_copy_button_button_up() -> void:
	Log.save_copy()


func _on_stop_button_mouse_entered() -> void: 
	tooltip_label.text = "[font_size=12]Stops the active session."

func _on_stop_button_mouse_exited() -> void: 
	tooltip_label.text = ""

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
	tooltip_label.text = "[font_size=12]Move category monitoring panel to left." if fileinfo_side else "[font_size=12]Move category monitoring panel to right."
	fileinfo_side_button.text = "Move to left side" if fileinfo_side else "Move to right side"

func _on_fileinfo_pos_mouse_exited() -> void:
	tooltip_label.text = ""
	fileinfo_side_button.text = ""
#endregion
