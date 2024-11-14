@tool
extends Control 
#region Documentation and declarations
## An optional controller to help manage logging sessions along with some additional features and information.

# @onready var main_hbox : HBoxContainer = %MainHBoxContainer
@onready var gologger_icon : Button = %GoLoggerIconFlat
@onready var session_status_panel : Panel = %SessionStatusPanel

## Session status button.
@onready var session_status_label : RichTextLabel = %SessionStatusLabel

## Start session button.
@onready var start_btn : Button = %StartButton

## Copy session button.
@onready var copy_btn : Button = %CopyButton

## Stop session button.
@onready var stop_btn : Button = %StopButton

@onready var update_timer : Timer = %UpdateTimer

var dockscript = preload("res://addons/GoLogger/Dock/GoLoggerDock.gd")
var dock = dockscript.new()

var visible_state : bool = false:
	set(value):
		visible_state      =  value 
		# start_btn.disabled = !value
		# copy_btn.disabled  = !value 
		# stop_btn.disabled  = !value 
		toggle_controller()

var current_position : int = 0

const PATH = "user://GoLogger/settings.ini"
var config = ConfigFile.new() 
#endregion


func _unhandled_input(event: InputEvent) -> void:
	if Engine.is_editor_hint():
		if event is InputEventKey and Log.hotkey_controller_toggle.shortcut.matches_event(event) and event.is_released():	
			visible = !visible
		if event is InputEventJoypadButton and Log.hotkey_controller_toggle.shortcut.matches_event(event) and event.is_released():
			visible = !visible


func _ready() -> void:
	if !Engine.is_editor_hint():
		config.load(PATH) 
		
		# update_timer.timeout.connect(_on_update_timer_timeout)
		update_timer.start()
		Log.session_status_changed.connect(_on_session_status_changed)  
		gologger_icon.mouse_entered.connect(_on_mouse_entered)
		gologger_icon.mouse_exited.connect(_on_mouse_exited)
		gologger_icon.button_up.connect(_on_button_up.bind(gologger_icon))
		start_btn.button_up.connect(_on_button_up.bind(start_btn)) 
		copy_btn.button_up.connect(_on_button_up.bind(copy_btn))
		stop_btn.button_up.connect(_on_button_up.bind(stop_btn))
		
		session_status_label.text = str("[font_size=6]\n[center][font_size=11] Session status:\n[center][color=green]ON") if Log.session_status else str("[font_size=6]\n[center][font_size=12] Session status:\n[center][color=red]OFF") 
		gologger_icon.mouse_filter = Control.MOUSE_FILTER_PASS 
	else:
		config.load(PATH)
		# update_timer.timeout.connect(_on_update_timer_timeout)
		update_timer.start()


# func _on_update_timer_timeout() -> void:
# 	config.load(PATH)
# 	var val = config.get_value("settings", "controller_position")
# 	if val != null: 
# 		current_position = val
# 		set_anchors_preset(val)
# 		set_positions() 

 


func _physics_process(delta: float) -> void:
	if Engine.is_editor_hint():
		size = Vector2.ZERO


func set_positions(pos : int) -> void:
	current_position = config.get_value("settings", "controller_position")
	set_anchors_preset(current_position)
	# match current_position:
	# 	0: set_anchors_preset(Control.LayoutPreset.PRESET_TOP_LEFT)
	# 	1: set_anchors_preset(Control.LayoutPreset.PRESET_CENTER_LEFT)
	# 	2: set_anchors_preset(Control.LayoutPreset.PRESET_BOTTOM_LEFT)
	# 	3: set_anchors_preset(Control.LayoutPreset.PRESET_TOP_RIGHT)
	# 	4: set_anchors_preset(Control.LayoutPreset.PRESET_CENTER_RIGHT)
	# 	5: set_anchors_preset(Control.LayoutPreset.PRESET_BOTTOM_RIGHT)  

	match pos:
		0: # L-top
			pivot_offset = Vector2.ZERO
			gologger_icon.pivot_offset = Vector2.ZERO
			session_status_panel.pivot_offset = Vector2.ZERO
			start_btn.pivot_offset = Vector2.ZERO
			copy_btn.pivot_offset = Vector2.ZERO
			stop_btn.pivot_offset = Vector2.ZERO
		1: # L-center
			pivot_offset = Vector2(0, size.y / 2)
			gologger_icon.pivot_offset = Vector2(0, gologger_icon.size.y / 2)
			session_status_panel.pivot_offset = Vector2(0, session_status_panel.size.y / 2)
			start_btn.pivot_offset = Vector2(0, start_btn.size.y / 2)
			copy_btn.pivot_offset = Vector2(0, copy_btn.size.y / 2)
			stop_btn.pivot_offset = Vector2(0, stop_btn.size.y / 2)
		2: # L-bottom
			pivot_offset = Vector2(0, size.y)
			gologger_icon.pivot_offset = Vector2(0, gologger_icon.size.y)
			session_status_panel.pivot_offset = Vector2(0, session_status_panel.size.y)
			start_btn.pivot_offset = Vector2(0, start_btn.size.y)
			copy_btn.pivot_offset = Vector2(0, copy_btn.size.y)
			stop_btn.pivot_offset = Vector2(0, stop_btn.size.y)

		3: # R-top
			pivot_offset = Vector2(size.x, 0)
			gologger_icon.pivot_offset = Vector2(gologger_icon.size.x, 0)
			session_status_panel.pivot_offset = Vector2(session_status_panel.size.x, 0)
			start_btn.pivot_offset = Vector2(start_btn.size.x, 0)
			copy_btn.pivot_offset = Vector2(copy_btn.size.x, 0)
			stop_btn.pivot_offset = Vector2(stop_btn.size.x, 0)

		4: # R-center
			pivot_offset = Vector2(size.x, size.y / 2)
			gologger_icon.pivot_offset = Vector2(gologger_icon.size.x, gologger_icon.size.y / 2)
			session_status_panel.pivot_offset = Vector2(session_status_panel.size.x, session_status_panel.size.y / 2)
			start_btn.pivot_offset = Vector2(start_btn.size.x, start_btn.size.y / 2)
			copy_btn.pivot_offset = Vector2(copy_btn.size.x, copy_btn.size.y / 2)
			stop_btn.pivot_offset = Vector2(stop_btn.size.x, stop_btn.size.y / 2)

		5: # R-bottom
			pivot_offset = Vector2(size.x, size.y)
			gologger_icon.pivot_offset = Vector2(gologger_icon.size.x, gologger_icon.size.y)
			session_status_panel.pivot_offset = Vector2(session_status_panel.size.x, session_status_panel.size.y)
			start_btn.pivot_offset = Vector2(start_btn.size.x, start_btn.size.y)
			copy_btn.pivot_offset = Vector2(copy_btn.size.x, copy_btn.size.y)
			stop_btn.pivot_offset = Vector2(stop_btn.size.x, stop_btn.size.y)
	
	gologger_icon.position = Vector2(5, 5) if current_position < 3 else Vector2(277, 5)
	session_status_panel.position = gologger_icon.position
	start_btn.position = gologger_icon.position
	copy_btn.position = gologger_icon.position
	stop_btn.position = gologger_icon.position
	
	gologger_icon.scale = Vector2(0.5, 0.5)
	session_status_panel.scale = Vector2(0.5, 0.5)
	start_btn.scale = Vector2(0.5, 0.5)
	copy_btn.scale = Vector2(0.5, 0.5)
	stop_btn.scale = Vector2(0.5, 0.5)
	
	gologger_icon.modulate = Color(1, 1, 1, 0.4) 
	session_status_panel.visible = false
	session_status_panel.modulate = Color.TRANSPARENT
	start_btn.visible = false
	start_btn.modulate = Color.TRANSPARENT
	copy_btn.visible = false
	copy_btn.modulate = Color.TRANSPARENT
	stop_btn.visible = false
	stop_btn.modulate = Color.TRANSPARENT





func toggle_controller() -> void: 
	

	# pivot_offset.x = 0 if current_position < 2 else 326
	var left_aligned : Array[Vector2] = [
		Vector2(5,   5),     # Icon
		Vector2(56,  5),     # Session Status
		Vector2(124, 5),     # Start
		Vector2(192, 5),     # Copy
		Vector2(260, 5)]     # Stop

	var right_aligned : Array[Vector2] =[
		Vector2(277, 5),     # Icon
		Vector2(209, 5),     # Session Status
		Vector2(141, 5),     # Start
		Vector2(73,  5),     # Copy
		Vector2(5,   5)]     # Stop
	var collapse_pos = Vector2(5, 5)

	var tw = get_tree().create_tween()
	tw.set_trans(Tween.TRANS_CUBIC)
	tw.set_ease(Tween.EASE_IN_OUT)
	tw.set_parallel(true)
	printt(str("Controller_toggle(", visible_state, "):\n\tcurrent_position: ", current_position, ))
	
	if visible_state:
		session_status_panel.visible = true
		start_btn.visible = true
		copy_btn.visible = true
		stop_btn.visible = true
		
		# Scale
		tw.tween_property(gologger_icon,        "scale", Vector2(1.0, 1.0),  0.05) 
		tw.tween_property(session_status_panel, "scale", Vector2(1.0, 1.0),  0.05) 
		tw.tween_property(start_btn,            "scale", Vector2(1.0, 1.0),  0.05) 
		tw.tween_property(copy_btn,             "scale", Vector2(1.0, 1.0),  0.05) 
		tw.tween_property(stop_btn,             "scale", Vector2(1.0, 1.0),  0.05) 
		# tw.tween_property(self,                 "scale", Vector2(1, 1), 0.05)

		# Position
		tw.tween_property(session_status_panel, "position", left_aligned[1] if current_position < 3 else right_aligned[1], 0.05) 
		tw.tween_property(start_btn,            "position", left_aligned[2] if current_position < 3 else right_aligned[2], 0.05)
		tw.tween_property(copy_btn, 	        "position", left_aligned[3] if current_position < 3 else right_aligned[3], 0.05)
		tw.tween_property(stop_btn,             "position", left_aligned[4] if current_position < 3 else right_aligned[4], 0.05)

		# Modulate
		tw.tween_property(session_status_panel, "modulate", Color.WHITE, 0.05)
		tw.tween_property(start_btn,            "modulate", Color(0.553, 0.859, 0.337), 0.05)
		tw.tween_property(copy_btn,             "modulate", Color(1, 0.871, 0.141)    , 0.05)
		tw.tween_property(stop_btn,             "modulate", Color(1, 0.29, 0.29)      , 0.05)
	else:
		# Scale
		tw.tween_property(gologger_icon,        "scale", Vector2(0.5, 0.5),  0.05) 
		tw.tween_property(session_status_panel, "scale", Vector2(0.5, 0.5),  0.05) 
		tw.tween_property(start_btn,            "scale", Vector2(0.5, 0.5),  0.05) 
		tw.tween_property(copy_btn,             "scale", Vector2(0.5, 0.5),  0.05) 
		tw.tween_property(stop_btn,             "scale", Vector2(0.5, 0.5),  0.05) 

		# Position
		tw.tween_property(session_status_panel, "position", left_aligned[0] if current_position < 3 else right_aligned[0], 0.05)
		tw.tween_property(start_btn,            "position", left_aligned[0] if current_position < 3 else right_aligned[0], 0.05)
		tw.tween_property(copy_btn,             "position", left_aligned[0] if current_position < 3 else right_aligned[0], 0.05)
		tw.tween_property(stop_btn,             "position", left_aligned[0] if current_position < 3 else right_aligned[0], 0.05)
		
		# Modulate
		tw.tween_property(session_status_panel, "modulate", Color.TRANSPARENT, 0.05)
		tw.tween_property(start_btn,            "modulate", Color.TRANSPARENT, 0.05)
		tw.tween_property(copy_btn,             "modulate", Color.TRANSPARENT, 0.05)
		tw.tween_property(stop_btn,             "modulate", Color.TRANSPARENT, 0.05)
	 	
		session_status_panel.visible = false
		start_btn.visible = false
		copy_btn.visible = false
		stop_btn.visible = false


func _on_mouse_entered() -> void:
	gologger_icon.modulate = Color(1, 1, 1, 1)

func _on_mouse_exited() -> void:
	gologger_icon.modulate = Color(1, 1, 1, 0.4)


#region Signal listeners
## Called when [signal session_status_changed] is emitted from [Log].
func _on_session_status_changed() -> void:
	session_status_label.text = str("[font_size=6]\n[center][font_size=11] Session:\n[center][color=green]ON") if Log.session_status else str("[font_size=6]\n[center][font_size=11] Session:\n[center][color=red]OFF")


func _on_visibility_toggle() -> void:
	toggle_controller()
 
 
func _on_button_up(button : Button) -> void: 
	match button:
		gologger_icon:
			visible_state = !visible_state
		start_btn:
			Log.start_session()
		copy_btn:
			Log.save_copy()
		stop_btn:
			Log.stop_session()   
#endregion
