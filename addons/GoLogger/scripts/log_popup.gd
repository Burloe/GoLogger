@tool
extends PopupPanel

@onready var top_bar: Panel = %TopBar
@onready var resize_handle: TextureRect = %ResizeHandle
@onready var copy_btn: Button = %CopyButton
@onready var settings_btn: Button = %SettingsButton
@onready var close_btn: Button = %CloseButton
@onready var content_lbl: Label = %ContentLabel

var dragging: bool = false
var first_popup := true
var saved_position := Vector2i.ZERO

var resizing := false

var content: String = "":
	set(value):
		content = value
		content_lbl.text = value



func _ready() -> void:
	assign_icons()
	about_to_popup.connect(_on_about_to_popup)
	resize_handle.gui_input.connect(_on_resize_handle_gui_input)
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



func _on_resize_handle_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			resizing = event.pressed

	elif event is InputEventMouseMotion and resizing:
		var new_size: Vector2i = Vector2i(
			int(size.x) + event.relative.x,
			int(size.y) + event.relative.y
		)

		new_size.x = max(int(new_size.x), 300)
		new_size.y = max(int(new_size.y), 200)

		size = new_size