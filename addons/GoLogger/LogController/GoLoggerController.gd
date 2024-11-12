@tool
extends Panel 
#region Documentation and declarations
## An optional controller to help manage logging sessions along with some additional features and information.

@onready var main_hbox : HBoxContainer = %MainHBoxContainer
@onready var gologger_icon : TextureRect = %GoLoggerIconFlat
@onready var session_status_panel : Panel = %SessionStatusPanel
@onready var btn_container : HBoxContainer = %FuncButtonContainer
## Session status button.
@onready var session_status_label : RichTextLabel = %SessionStatusLabel


## Start session button.
@onready var start_btn : Button = %StartButton

## Copy session button.
@onready var copy_btn : Button = %CopyButton

## Stop session button.
@onready var stop_btn : Button = %StopButton

## Toggles the visibility state of the controller.
@onready var toggle_btn : Button = %ToggleButton

var icons : Array = [
	preload("res://addons/GoLogger/Resources/icons/ArrowUp.svg"),
	preload("res://addons/GoLogger/Resources/icons/ArrowRight.svg"),
	preload("res://addons/GoLogger/Resources/icons/ArrowDown.svg"),
	preload("res://addons/GoLogger/Resources/icons/ArrowLeft.svg")
]

@export var visible_state : bool = false 

var hidepos : Vector2 = Vector2.ZERO
var showpos : Vector2 = Vector2.ZERO
var toggle_btn_pos : Vector2 = Vector2.ZERO

enum CONTROLLER_POSITION {
	CENTER_TOP,
	RIGHT_TOP,
	RIGHT_CENTER,
	RIGHT_BOTTOM,
	CENTER_BOTTOM,
	LEFT_BOTTOM,
	LEFT_CENTER,
	LEFT_TOP
}

@export var current_position = CONTROLLER_POSITION.LEFT_TOP:
	set(value):
		# printt(main_hbox, gologger_icon, session_status_panel, btn_container, session_status_label)
		set_positions()

const PATH = "user://GoLogger/settings.ini"
var config = ConfigFile.new()
var categories 
#endregion




func _unhandled_input(event: InputEvent) -> void:
	# if event is InputEventKey and Log.hotkey_controller_toggle.shortcut.matches_event(event) and event.is_released():	
	# 	visible = !visible
	# if event is InputEventJoypadButton and Log.hotkey_controller_toggle.shortcut.matches_event(event) and event.is_released():
	# 	visible = !visible
	
	if event is InputEventKey and event.keycode == KEY_C and event.is_released():
		current_position = randi_range(0, 7)



func _ready() -> void:
	if !Engine.is_editor_hint():
		config.load(PATH)
		categories = config.get_value("plugin", "categories")
		
		Log.session_status_changed.connect(_on_session_status_changed) 
		Log.toggle_controller.connect(_on_visibility_toggle)
		start_btn.button_up.connect(_on_button_up.bind(start_btn)) 
		copy_btn.button_up.connect(_on_button_up.bind(copy_btn))
		stop_btn.button_up.connect(_on_button_up.bind(stop_btn)) 
		toggle_btn.button_up.connect(_on_button_up.bind(toggle_btn))
		
		session_status_label.text = str("[font_size=6]\n[center][font_size=11] Session status:\n[center][color=green]ON") if Log.session_status else str("[font_size=6]\n[center][font_size=12] Session status:\n[center][color=red]OFF")

		set_positions()
		match current_position:
			CONTROLLER_POSITION.CENTER_TOP:
				if visible_state:
					toggle_btn.icon = icons[0]
				else:
					toggle_btn.icon = icons[2]
			CONTROLLER_POSITION.RIGHT_TOP:
				if visible_state:
					toggle_btn.icon = icons[3]
				else:
					toggle_btn.icon = icons[1]
			CONTROLLER_POSITION.RIGHT_CENTER:
				if visible_state:
					toggle_btn.icon = icons[3]
				else:
					toggle_btn.icon = icons[1]
			CONTROLLER_POSITION.RIGHT_BOTTOM:
				if visible_state:
					toggle_btn.icon = icons[3]
				else:
					toggle_btn.icon = icons[1]
			CONTROLLER_POSITION.CENTER_BOTTOM:
				if visible_state:
					toggle_btn.icon = icons[2]
				else:
					toggle_btn.icon = icons[0]
			CONTROLLER_POSITION.LEFT_TOP:
				if visible_state:
					toggle_btn.icon = icons[3]
				else:
					toggle_btn.icon = icons[1]
			CONTROLLER_POSITION.LEFT_CENTER:
				if visible_state:
					toggle_btn.icon = icons[3]
				else:
					toggle_btn.icon = icons[1]
			CONTROLLER_POSITION.LEFT_BOTTOM:
				if visible_state:
					toggle_btn.icon = icons[3]
				else:
					toggle_btn.icon = icons[1]



func set_positions() -> void:
	if visible_state:
		start_btn.disabled = false
		copy_btn.disabled  = false
		stop_btn.disabled  = false
	else:
		start_btn.disabled = true
		copy_btn.disabled  = true
		stop_btn.disabled  = true

	match current_position:
		CONTROLLER_POSITION.CENTER_TOP:
			main_hbox.move_child(gologger_icon, 0)
			main_hbox.move_child(session_status_panel, 1)
			main_hbox.move_child(btn_container, 2)
			btn_container.move_child(stop_btn,  0)
			btn_container.move_child(copy_btn,  1)
			btn_container.move_child(start_btn, 2)
			hidepos  = Vector2(779, -62)
			showpos  = Vector2(779, 5) 
			toggle_btn.icon = icons[2]
			toggle_btn.size = Vector2(62, 32)
			toggle_btn_pos = Vector2(150, 67) 
		CONTROLLER_POSITION.RIGHT_TOP:
			main_hbox.move_child(btn_container, 0)
			main_hbox.move_child(session_status_panel, 1)
			main_hbox.move_child(gologger_icon, 2)
			btn_container.move_child(stop_btn,  0)
			btn_container.move_child(copy_btn,  1)
			btn_container.move_child(start_btn, 2)
			hidepos  = Vector2(1920, 5)
			showpos  = Vector2(1553, 5) 
			toggle_btn.icon = icons[3]
			toggle_btn.size = Vector2(32, 62)
			toggle_btn_pos = Vector2(-37, 0) 
		CONTROLLER_POSITION.RIGHT_CENTER:
			main_hbox.move_child(btn_container, 0)
			main_hbox.move_child(session_status_panel, 1)
			main_hbox.move_child(gologger_icon, 2)
			btn_container.move_child(stop_btn,  0)
			btn_container.move_child(copy_btn,  1)
			btn_container.move_child(start_btn, 2)
			hidepos  = Vector2(1920, 509)
			showpos  = Vector2(1553, 509) 
			toggle_btn.icon = icons[3]
			toggle_btn.size = Vector2(32, 62)
			toggle_btn_pos = Vector2(-37, 0) 
		CONTROLLER_POSITION.RIGHT_BOTTOM:
			main_hbox.move_child(btn_container, 0)
			main_hbox.move_child(session_status_panel, 1)
			main_hbox.move_child(gologger_icon, 2)
			btn_container.move_child(stop_btn,  0)
			btn_container.move_child(copy_btn,  1)
			btn_container.move_child(start_btn, 2)
			hidepos  = Vector2(1920, 1013)
			showpos  = Vector2(1553, 1013) 
			toggle_btn.icon = icons[3]
			toggle_btn.size = Vector2(32, 62)
			toggle_btn_pos = Vector2(-37, 0) 
		CONTROLLER_POSITION.CENTER_BOTTOM:
			main_hbox.move_child(btn_container, 0)
			main_hbox.move_child(session_status_panel, 1)
			main_hbox.move_child(gologger_icon, 2)
			btn_container.move_child(start_btn, 0)
			btn_container.move_child(copy_btn,  1)
			btn_container.move_child(stop_btn,  2)
			hidepos  = Vector2(779, 1075)
			showpos  = Vector2(779, 1013) 
			toggle_btn.icon = icons[0]
			toggle_btn.size = Vector2(62, 32)
			toggle_btn_pos = Vector2(150, -37) 
		CONTROLLER_POSITION.LEFT_BOTTOM:
			main_hbox.move_child(gologger_icon, 0)
			main_hbox.move_child(session_status_panel, 1)
			main_hbox.move_child(btn_container, 2)
			btn_container.move_child(start_btn, 0)
			btn_container.move_child(copy_btn,  1)
			btn_container.move_child(stop_btn,  2)
			hidepos = Vector2(-362, 1013)
			showpos  = Vector2(5, 1013) 
			toggle_btn.icon = icons[1]
			toggle_btn.size = Vector2(32, 62)
			toggle_btn_pos = Vector2(367, 0) 
		CONTROLLER_POSITION.LEFT_CENTER:
			main_hbox.move_child(gologger_icon, 0)
			main_hbox.move_child(session_status_panel, 1)
			main_hbox.move_child(btn_container, 2)
			btn_container.move_child(start_btn, 0)
			btn_container.move_child(copy_btn,  1)
			btn_container.move_child(stop_btn,  2)
			hidepos  = Vector2(-362, 509)
			showpos  = Vector2(5, 509) 
			toggle_btn.icon = icons[1]
			toggle_btn.size = Vector2(32, 62)
			toggle_btn_pos = Vector2(367, 0) 
		CONTROLLER_POSITION.LEFT_TOP:
			main_hbox.move_child(gologger_icon, 0)
			main_hbox.move_child(session_status_panel, 1)
			main_hbox.move_child(btn_container, 2)
			btn_container.move_child(start_btn, 0)
			btn_container.move_child(copy_btn,  1)
			btn_container.move_child(stop_btn,  2)
			hidepos  = Vector2(-362, 5)
			showpos	 = Vector2(5, 5) 
			toggle_btn.icon = icons[1]
			toggle_btn.size = Vector2(32, 62)
			toggle_btn_pos = Vector2(367, 0) 

	position = showpos if visible_state else hidepos
	toggle_btn.position = toggle_btn_pos

func toggle_controller() -> void:
	visible_state = !visible_state
	var tw = get_tree().create_tween()
	tw.set_trans(Tween.TRANS_CUBIC)
	tw.set_ease(Tween.EASE_IN_OUT)
	tw.tween_property(self, "position", showpos if visible_state else hidepos, 0.08) 
	match current_position:
		CONTROLLER_POSITION.CENTER_TOP:
			if visible_state:
				toggle_btn.icon = icons[0]
			else:
				toggle_btn.icon = icons[2]
		CONTROLLER_POSITION.RIGHT_TOP:
			if visible_state:
				toggle_btn.icon = icons[3]
			else:
				toggle_btn.icon = icons[1]
		CONTROLLER_POSITION.RIGHT_CENTER:
			if visible_state:
				toggle_btn.icon = icons[3]
			else:
				toggle_btn.icon = icons[1]
		CONTROLLER_POSITION.RIGHT_BOTTOM:
			if visible_state:
				toggle_btn.icon = icons[3]
			else:
				toggle_btn.icon = icons[1]
		CONTROLLER_POSITION.CENTER_BOTTOM:
			if visible_state:
				toggle_btn.icon = icons[2]
			else:
				toggle_btn.icon = icons[0]
		CONTROLLER_POSITION.LEFT_TOP:
			if visible_state:
				toggle_btn.icon = icons[3]
			else:
				toggle_btn.icon = icons[1]
		CONTROLLER_POSITION.LEFT_CENTER:
			if visible_state:
				toggle_btn.icon = icons[3]
			else:
				toggle_btn.icon = icons[1]
		CONTROLLER_POSITION.LEFT_BOTTOM:
			if visible_state:
				toggle_btn.icon = icons[3]
			else:
				toggle_btn.icon = icons[1]


#region Signal listeners
## Called when [signal session_status_changed] is emitted from [Log].
func _on_session_status_changed() -> void:
	session_status_label.text = str("[font_size=6]\n[center][font_size=11] Session status:\n[center][color=green]ON") if Log.session_status else str("[font_size=6]\n[center][font_size=11] Session status:\n[center][color=red]OFF")


func _on_visibility_toggle() -> void:
	toggle_controller()
 
 
func _on_button_up(button : Button) -> void:
	print("bar")
	match button:
		start_btn:
			Log.start_session()
		copy_btn:
			Log.save_copy()
		stop_btn:
			Log.stop_session()  
		toggle_btn: 
			toggle_controller()
#endregion
