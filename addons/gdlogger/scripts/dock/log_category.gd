@tool
class_name GDLLogCategory extends PanelContainer

## Emitted to dock.gd when any change is made in order to save the categories.
signal log_category_changed 
## Emitted to dock.gd to move the categories and save them.
signal move_category_requested(log_category: GDLLogCategory, direction : int)

signal set_default_category(category: GDLLogCategory, toggle_on: bool) 
## Emitted to dock_logs.gd to display the prompt and await user input before executing deletion and directory cleanup
signal show_delete_category_prompt(category: GDLLogCategory)


@export var data: GDLData = null
@export var cat_data: GDLCategoryData = null

@onready var move_left_btn: Button = 				%MoveLeftButton
@onready var move_right_btn: Button = 			%MoveRightButton
@onready var select_btn:	Button = 					%SelectButton
@onready var default_btn: Button =	 				%DefaultButton
@onready var line_edit: LineEdit = 					%CategoryNameLineEdit
@onready var del_btn:	Button = 							%DeleteButton

@onready var line_edit_panel: Panel = 			%LineEditPanel
@onready var edit_hbox: HBoxContainer = 		%LineEditHBox
@onready var apply_btn: Button = 						%ApplyButton
@onready var revert_btn: Button = 					%RevertButton
@onready var faky: Control = 								%Faky

@onready var settings = EditorInterface.get_editor_settings()
@onready var editor_base_col: Color = settings.get("interface/theme/base_color")
@onready var editor_accent_col: Color = settings.get("interface/theme/accent_color") 

var size_unedited: Vector2 = size # 210, 48)
var size_edited = Vector2(size_unedited.x + 52, 48)# var size_edited = Vector2(262, 48)
##  Last applied category name
var category_name: String = "":
	set(value):
		if category_name != value:
			category_name = value.to_lower()

			if cat_data != null:
				cat_data.category_name = value

			if line_edit != null: line_edit.text = category_name

			if default_btn:
				default_btn.disabled = category_name.is_empty() 

## Only used to assign icon -> use default_btn.button_pressed to check if def
var is_default: bool = false:
	set(value):
		is_default = value
		default_btn.icon = get_theme_icon("GuiRadioUncheckedDisabled" if category_name.is_empty() else "GuiRadioChecked" if value else "GuiRadioUnchecked", "EditorIcons")

var has_unapplied_name: bool = false:
	set(value):
		has_unapplied_name = value
		if value and !is_editing_name:
			_tween_line_edit_module(true)
		elif !value and !is_editing_name:
			_tween_line_edit_module(false)

var is_editing_name: bool = false:
	set(value):
		is_editing_name = value
		if value and !has_unapplied_name:
			_tween_line_edit_module(true)
		elif !value and !has_unapplied_name:
			_tween_line_edit_module(false)

var is_new: bool = false:
	set(value):
		is_new = value
		if value:
			size = size_edited

var is_selected: bool = false:
	set(value):
		is_selected = value
		select_btn.disabled = value



func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.keycode == KEY_ESCAPE:
		if line_edit.has_focus():
			line_edit.release_focus()



func _ready() -> void:
	_on_editor_settings_changed() 
	settings.settings_changed.connect(_on_editor_settings_changed)
	line_edit.text_changed.connect(_on_text_changed)
	del_btn.button_up.connect(_on_del_button_up)
	select_btn.toggled.connect(func(toggle_on) -> void: is_selected = toggle_on)
	move_left_btn.button_up.connect(func() -> void: move_category_requested.emit(self, -1))
	move_right_btn.button_up.connect(func() -> void: move_category_requested.emit(self, 1))

	line_edit.text_submitted.connect(apply_name) 
	apply_btn.button_up.connect(func() -> void: apply_name(line_edit.text))

	is_default = is_default # loads the icon
	apply_btn.disabled = line_edit.text.is_empty()
	revert_btn.disabled = false
	line_edit.size.x = 110

	revert_btn.button_up.connect(
		func() -> void:
			# line_edit.unedit()
			line_edit.release_focus()
			line_edit.text = category_name
			line_edit_panel.hide()
	)

	line_edit.editing_toggled.connect(
		func(toggled_on: bool) -> void: 
			revert_btn.tooltip_text = str("Revert to '", category_name, "'")
			is_editing_name = toggled_on
			if category_name == line_edit.text or line_edit.text.is_empty(): 
				apply_btn.disabled =  true
			else: 
				apply_btn.disabled = false
	)

	default_btn.toggled.connect(
		func(toggled_on: bool) -> void:
			set_default_category.emit(self, toggled_on)
			is_default = toggled_on
			if cat_data:
				cat_data.is_default = toggled_on
	)

	default_btn.disabled = category_name.is_empty()
	size = Vector2.ZERO 


func _tween_line_edit_module(show: bool = false) -> void:
	if is_new:
		size = size_edited
		is_new = false
		line_edit_panel.show()
		line_edit_panel.modulate = Color.WHITE
		return
	
	var tw := create_tween().set_parallel(true)
	faky.visible = show
	faky.size.x = 0 if show else 42
	tw.tween_property(self, "size", size_edited if show else size_unedited, 0.03)
	tw.tween_property(faky, "size", Vector2(42 if show else 0, faky.size.y), 0.03)
	await tw.finished
	var tween := create_tween()
	faky.visible = !show
	faky.size.x = 0
	line_edit_panel.visible  = show
	line_edit_panel.modulate = Color.TRANSPARENT if show else Color.WHITE
	tween.tween_property(line_edit_panel, "modulate", Color.WHITE if show else Color.TRANSPARENT, 0.03)



func _data_ready() -> void:
	if category_name != "":
		revert_btn.tooltip_text = str("Revert to '", category_name, "'")

	line_edit.text = category_name
	default_btn.disabled = category_name.is_empty()



func is_name_available(_name: String) -> bool: 
	return !_name in data.get_category_names()



func apply_name(new_name: String) -> void:
	if !is_name_available(new_name) or new_name.is_empty():
		line_edit.text = category_name
		line_edit.unedit()
		line_edit.set_theme_type_variation("LineEdit_category_field_valid")
		_tween_line_edit_module(false)
		has_unapplied_name = false
		return 
	
	elif new_name == category_name:
		line_edit.release_focus()
		line_edit.unedit()
		_tween_line_edit_module(false)
		has_unapplied_name = false
		return


	new_name = new_name.replace(" ", "_")
	var cat_names = data.get_category_names()
	var def: String = data.default_category
	
	if category_name == "": # Naming new category
		var new: GDLCategoryData = GDLCategoryData.new()
		new.category_name = new_name
		data.categories.append(new)
		cat_data = new

	else: # Renaming existing category
		if !cat_data:
			cat_data = GDLCategoryData.new()
		cat_data.category_name = new_name
	
	cat_data.category_path = str(data.base_dir, new_name, "_logs/")
	category_name = new_name
	line_edit.text = category_name
	log_category_changed.emit()
	line_edit.release_focus()
	has_unapplied_name = false



func _on_text_changed(new_text: String) -> void:
	var c_column = line_edit.caret_column
	line_edit.text = line_edit.text.validate_filename()
	new_text = new_text.replace(" ", "_")
	line_edit.caret_column = c_column

	has_unapplied_name = new_text not in [category_name, ""]

	if new_text.is_empty() or !is_name_available(new_text) and category_name != new_text: 
		apply_btn.disabled = true
		line_edit.set_theme_type_variation("LineEdit_CategoryFieldInvalid")
	else:
		apply_btn.disabled = new_text == category_name
		line_edit.set_theme_type_variation("LineEdit_CategoryFieldValid")



func _on_del_button_up() -> void:
	if category_name.is_empty():
		queue_free()
	else:
		show_delete_category_prompt.emit(self)



func _get_theme_colors() -> Dictionary: # Returns a structured palette based on current editor theme
	var contrast: float = settings.get("interface/theme/contrast")
	var base_col: Color = settings.get("interface/theme/base_color")
	var accent_col: Color = settings.get("interface/theme/accent_color")

	var base_light: Color 		= base_col.lerp(Color.WHITE, contrast)
	var base_dark: Color 			= base_col.lerp(Color.BLACK, contrast)
	var base_light_h: Color 	= base_col.lerp(Color.WHITE, contrast * 0.5)
	var base_dark_h: Color 		= base_col.lerp(Color.BLACK, contrast * 0.5)

	var accent_light: Color 	= accent_col.lerp(Color.WHITE, contrast)
	var accent_dark: Color 		= accent_col.lerp(Color.BLACK, contrast)
	var accent_light_h: Color = accent_col.lerp(Color.WHITE, contrast * 0.5)
	var accent_dark_h: Color 	= accent_col.lerp(Color.BLACK, contrast * 0.5)

	var colors := {
		"contrast": contrast,
		"base": {
			"col": base_col,
			"light": base_light,
			"dark": base_dark,
			"light_highlight": base_light_h,
			"dark_highlight": base_dark_h,
		},
		"accent": {
			"col": accent_col,
			"light": accent_light,
			"dark": accent_dark,
			"light_highlight": accent_light_h,
			"dark_highlight": accent_dark_h,
		},
		"font": {
			"normal": Color(0.878, 0.878, 0.878),
			"hover": Color(0.95, 0.95, 0.95),
			"interact_normal": base_col,
			"interact_hover": base_light,
			"interact_pressed": base_col,
			"interact_hover_pressed": base_light
		}
	}
	return colors



func _on_editor_settings_changed() -> void:
	var _c: Dictionary = _get_theme_colors()
	for btn in [move_left_btn, move_right_btn]:
		if btn != null: 
			btn.add_theme_color_override("icon_hover_color", _c["accent"]["light"])
			btn.add_theme_color_override("icon_pressed_color", _c["accent"]["dark"])
			btn.add_theme_color_override("icon_hover_pressed_color", _c["accent"]["dark"])
	select_btn.add_theme_color_override("icon_color", Color.BLACK.lightened(0.2) if settings.get_setting("interface/theme/accent_color").get_luminance() > 0.5 else Color.WHITE.darkened(0.1))
	select_btn.add_theme_color_override("icon_color", Color.BLACK.lightened(0.2) if settings.get_setting("interface/theme/accent_color").get_luminance() > 0.5 else Color.WHITE.darkened(0.1))
	select_btn.add_theme_color_override("icon_hover_color", Color.BLACK.lightened(0.2) if settings.get_setting("interface/theme/accent_color").get_luminance() > 0.5 else Color.WHITE.darkened(0.1))
	select_btn.add_theme_color_override("icon_pressed_color", Color.BLACK.lightened(0.2) if settings.get_setting("interface/theme/accent_color").get_luminance() > 0.5 else Color.WHITE.darkened(0.1))
	select_btn.add_theme_color_override("icon_hover_pressed_color", Color.BLACK.lightened(0.2) if settings.get_setting("interface/theme/accent_color").get_luminance() > 0.5 else Color.WHITE.darkened(0.1))
