@tool
extends PopupPanel

signal close_logfile

@onready var top_bar: PanelContainer = %TopBar
@onready var resize_handle: TextureRect = %ResizeHandle
@onready var copy_btn: Button = %CopyButton
@onready var settings_btn: Button = %SettingsButton
@onready var close_btn: Button = %CloseButton
@onready var filename_lbl: Label = %FileNameLabel
@onready var content_scroll_container: ScrollContainer = %ContentScrollContainer
@onready var content_lbl: Label = %ContentLabel
@onready var lbsett_inspector: EditorInspector = %LblSettingsEditorInspector
@onready var settings = EditorInterface.get_editor_settings()

var file_contents_lblsett: String = "uid://cqn5x8cb7vjy3"
var first_popup := true
var saved_position := Vector2i.ZERO
var dragging: bool = false
var drag_offset := Vector2i.ZERO

var resizing := false
var resize_start_mouse := Vector2i.ZERO
var resize_start_size := Vector2i.ZERO

var file_name: String = "":
	set(value):
		file_name = value
		filename_lbl.text  = value

var content: String = "":
	set(value):
		content = value
		content_lbl.text = value



func _ready() -> void:
	about_to_popup.connect(_on_about_to_popup)
	resize_handle.gui_input.connect(_on_resize_handle_gui_input)
	copy_btn.button_up.connect(
		func() -> void:
			DisplayServer.clipboard_set(content_lbl.text)
	)
	settings_btn.toggled.connect(
		func(toggled: bool) -> void:
				lbsett_inspector.visible = toggled
	)
	close_btn.button_up.connect(func() -> void: hide())
	top_bar.gui_input.connect(_on_title_bar_gui_input)

	lbsett_inspector.edit(ResourceLoader.load(file_contents_lblsett))
	content_lbl.label_settings = load(file_contents_lblsett) 
	lbsett_inspector.hide()



func _on_about_to_popup() -> void:
	content_scroll_container.scroll_horizontal = 0
	content_scroll_container.scroll_vertical = 0
	if first_popup:
		first_popup = false
		call_deferred("_save_popup_position")

	else:
		initial_position = WindowInitialPosition.WINDOW_INITIAL_POSITION_ABSOLUTE
		position = saved_position



func _save_popup_position() -> void:
	saved_position = position



func _on_title_bar_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		dragging = event.pressed
		if dragging:
			drag_offset = DisplayServer.mouse_get_position() - position

	elif event is InputEventMouseMotion and dragging:
		position = DisplayServer.mouse_get_position() - drag_offset
		saved_position = position



func _on_resize_handle_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		resizing = event.pressed
		if resizing:
			resize_start_mouse = DisplayServer.mouse_get_position()
			resize_start_size = size

	elif event is InputEventMouseMotion and resizing:
		var new_size: Vector2i = resize_start_size + (DisplayServer.mouse_get_position() - resize_start_mouse)
		new_size.x = maxi(new_size.x, 300)
		new_size.y = maxi(new_size.y, 200)
		size = new_size


