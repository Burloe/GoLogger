@tool
extends PopupPanel

@onready var top_bar: Panel = %TopBar
@onready var resize_handle: TextureRect = %ResizeHandle
@onready var copy_btn: Button = %CopyButton
@onready var settings_btn: Button = %SettingsButton
@onready var close_btn: Button = %CloseButton
@onready var content_margin_container: MarginContainer = %ContentMarginContainer
@onready var content_lbl: Label = %ContentLabel
@onready var lbsett_panel: Panel = %LblSettingsPanel
@onready var lbsett_scroll_container: ScrollContainer = %LblSettingsScrollContainer

var inspector: EditorInspector = null
var file_contents_lblsett: String = "uid://cqn5x8cb7vjy3"
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
	copy_btn.button_up.connect(
		func() -> void:
			DisplayServer.clipboard_set(content_lbl.text)
	)
	settings_btn.toggled.connect(
		func(toggled: bool) -> void:
			if inspector:
				lbsett_panel.visible = toggled
	)
	close_btn.button_up.connect(func() -> void: hide())
	top_bar.gui_input.connect(_on_title_bar_gui_input)

	inspector = EditorInspector.new()
	lbsett_scroll_container.add_child(inspector)
	inspector.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	inspector.size_flags_vertical = Control.SIZE_EXPAND_FILL
	inspector.edit(ResourceLoader.load(file_contents_lblsett))
	content_lbl.label_settings = load(file_contents_lblsett) 
	lbsett_panel.hide()



func assign_icons() -> void:
	copy_btn.set_button_icon(get_theme_icon("ActionCopy", "EditorIcons"))
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