@tool
extends PopupPanel

@onready var top_bar: Panel = %TopBar
@onready var copy_btn: Button = %CopyButton
@onready var settings_btn: Button = %SettingsButton
@onready var close_btn: Button = %CloseButton
@onready var content_lbl: Label = %ContentLabel

var dragging: bool = false
var first_popup := true
var saved_position := Vector2i.ZERO

var content: String = "":
	set(value):
		content = value
		content_lbl.text = value



func _ready() -> void:
	assign_icons()
	about_to_popup.connect(_on_about_to_popup)
	close_btn.button_up.connect(func() -> void: hide())
	top_bar.gui_input.connect(_on_title_bar_gui_input)



func assign_icons() -> void:
	copy_btn.set_button_icon(get_theme_icon("CopyAction", "EditorIcons"))
	settings_btn.set_button_icon(get_theme_icon("GDScript", "EditorIcons"))
	close_btn.set_button_icon(get_theme_icon("Close", "EditorIcons"))



func _on_about_to_popup() -> void:
	if first_popup:
		first_popup = false
		call_deferred("_save_popup_position")

	else:
		initial_position = WindowInitialPosition.WINDOW_INITIAL_POSITION_ABSOLUTE
		position = saved_position



func _save_popup_position() -> void:
	saved_position = position



func _on_title_bar_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			dragging = event.pressed

	elif event is InputEventMouseMotion and dragging:
		position += Vector2i(event.relative.x, event.relative.y)
		saved_position = position 