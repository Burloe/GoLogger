@tool
class_name LogCategory extends PanelContainer

## Emitted to GoLoggerDock.gd when any change is made in order to save the categories.
signal log_category_changed 
## Emitted to GoLoggerDock.gd to move the categories and save them.
signal move_category_requested(log_category: LogCategory, direction : int)

signal set_default_category(category: LogCategory, toggle_on: bool) 

@onready var move_left_btn: Button = 				%MoveLeftButton
@onready var move_right_btn: Button = 			%MoveRightButton
@onready var lock_btn:	Button = 						%LockButton
@onready var default_checkbox: CheckBox = 	%DefaultCheckBox
@onready var line_edit: LineEdit = 					%CategoryNameLineEdit
@onready var del_btn:	Button = 							%DeleteButton
@onready var apply_btn: Button = 						%ApplyButton
@onready var revert_btn: Button = 					%RevertButton

@onready var settings = EditorInterface.get_editor_settings()
@onready var editor_base_col: Color = settings.get("interface/theme/base_color")
@onready var editor_accent_col: Color = settings.get("interface/theme/accent_color") 
var sb_line_edit_normal: StyleBoxFlat = preload("uid://pue22dsifmfd")
var sb_line_edit_invalid: StyleBoxFlat = preload("uid://cdij27b0tovx")

const PATH = "user://gologger_data.ini"
var config = ConfigFile.new() 

## Lock status (locks the category name and disables the erase button)
var is_locked : bool = false:
	set(value):
		is_locked = value
		log_category_changed.emit() 
		if lock_btn != null: lock_btn.button_pressed = is_locked
		if line_edit != null: line_edit.editable = !value
		if del_btn != null: del_btn.disabled = value

##  Last applied category name
var category_name: String = "":
	set(value):
		config.load(PATH)

		if category_name != value:
			category_name = value
			if line_edit != null: line_edit.text = category_name 

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.keycode == KEY_ESCAPE:
		if line_edit.has_focus():
			line_edit.release_focus()


func _ready() -> void:
	config.load(PATH)



	_on_editor_settings_changed() 
	revert_btn.hide()
	if category_name != "":
		revert_btn.tooltip_text = str("Revert to '", category_name, "'")

	settings.settings_changed.connect(_on_editor_settings_changed)
	del_btn.button_up.connect(_on_del_button_up)
	line_edit.text_changed.connect(_on_text_changed)
	line_edit.editing_toggled.connect(_on_line_edit_editing_toggled)
	line_edit.focus_exited.connect(_on_line_edit_focus_exited)
	move_left_btn.button_up.connect(func() -> void: move_category_requested.emit(self, -1))
	move_right_btn.button_up.connect(func() -> void: move_category_requested.emit(self, 1))

	revert_btn.button_up.connect(
		func() -> void:
			line_edit.unedit()
			line_edit.release_focus()
			line_edit.text = category_name
			apply_btn.hide()
			default_checkbox.show()
			revert_btn.hide()
	)

	line_edit.text_submitted.connect(
		func(new_text: String) -> void:
			if !check_name_conflict():
				apply_name(new_text)
			else:
				line_edit.text = category_name
				handle_name_state()
	)

	line_edit.text_changed.connect(
		func(_new_text: String) -> void:
			handle_name_state()
	)

	apply_btn.button_up.connect(
		func() -> void:
			if !check_name_conflict():
				apply_name(line_edit.text)
	)

	lock_btn.toggled.connect(
		func(pressed: bool) -> void:
			is_locked = pressed
			line_edit.unedit()
			line_edit.release_focus()
			apply_btn.hide()
			default_checkbox.show()
			revert_btn.hide()
	)

	default_checkbox.toggled.connect(
		func(pressed: bool) -> void:
			set_default_category.emit(self, pressed) 
	)

	line_edit.text = category_name
	lock_btn.button_pressed = is_locked
	size = Vector2.ZERO
	if line_edit.text == "": 
		apply_btn.hide() 



func handle_name_state() -> void:
	var is_unchanged := line_edit.text == "" or line_edit.text == category_name
	var has_conflict := check_name_conflict()

	apply_btn.visible = !is_unchanged
	apply_btn.disabled = is_unchanged or has_conflict
	default_checkbox.visible = is_unchanged



func check_name_conflict() -> bool:
	config.load(PATH)
	return config.get_value("categories", "category_names", []).has(line_edit.text)



func apply_name(new_name: String) -> void:
	if new_name.is_empty():
		return
		
	config.load(PATH)
	var low_name: String = new_name.to_lower()
	var cat: Array = config.get_value("categories", "category_names", []).duplicate()
	var def: String = config.get_value("categories", "default_category", "")
	var old_name: String = category_name

	# New LogCategory
	if old_name == "": 
		cat.append(low_name)

	# Existing LogCategory
	if cat.has(old_name) and old_name != "": 
		for c in cat.size():
			if cat[c] == old_name:
				cat[c] = low_name 
				break

	if old_name == def:
		config.set_value("categories", "default_category", low_name)

	config.set_value("categories", "category_names", cat)
	config.save(PATH) 

	category_name = low_name
	line_edit.text = low_name
	log_category_changed.emit()
	line_edit.release_focus()
	apply_btn.hide()
	default_checkbox.show()



func _on_text_changed(new_text: String) -> void:
	if new_text != category_name and category_name != "":
		line_edit.add_theme_stylebox_override("normal", sb_line_edit_invalid if check_name_conflict() else sb_line_edit_normal)



func _on_line_edit_editing_toggled(toggled_on: bool) -> void:
	if !is_locked:
		revert_btn.tooltip_text = str("Revert to '", category_name, "'")
		revert_btn.visible = toggled_on



func _on_line_edit_focus_exited() -> void:
	if line_edit.text == category_name:
		apply_btn.hide()
		default_checkbox.show()



func _on_del_button_up() -> void: 
	queue_free() # `exit_tree` signal handles saving categories after deletion



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
