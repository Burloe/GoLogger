@tool
class_name GLLogCategory extends PanelContainer

## Emitted to GoLoggerDock.gd when any change is made in order to save the categories.
signal log_category_changed 
## Emitted to GoLoggerDock.gd to move the categories and save them.
signal move_category_requested(log_category: GLLogCategory, direction : int)

signal set_default_category(category: GLLogCategory, toggle_on: bool) 


@export var data: GLData = null
@export var cat_data: GLCategoryData = null

@onready var move_left_btn: Button = 				%MoveLeftButton
@onready var move_right_btn: Button = 			%MoveRightButton
# @onready var lock_btn:	Button = 						%LockButton
@onready var default_btn: Button =	 				%DefaultButton
@onready var line_edit: LineEdit = 					%CategoryNameLineEdit
@onready var del_btn:	Button = 							%DeleteButton
@onready var apply_btn: Button = 						%ApplyButton
@onready var revert_btn: Button = 					%RevertButton

@onready var settings = EditorInterface.get_editor_settings()
@onready var editor_base_col: Color = settings.get("interface/theme/base_color")
@onready var editor_accent_col: Color = settings.get("interface/theme/accent_color") 
var sb_line_edit_normal: StyleBoxFlat = preload("uid://pue22dsifmfd")
var sb_line_edit_invalid: StyleBoxFlat = preload("uid://cdij27b0tovx")

const IDLE_SIZE = Vector2(242, 48)
const HOVER_SIZE = Vector2(334, 48)
const HOVER_EDGE_SIZE = Vector2(308, 48)
const EDITING_SIZE = Vector2(310, 48)

enum STATES {
	IDLE,
	HOVER,
	EDITING
}
var state: STATES = STATES.IDLE
var is_hovered: bool = false  
var state_transition_id: int = 0

##  Last applied category name
var category_name: String = "":
	set(value):
		if category_name != value:
			category_name = value.to_lower()

			if cat_data != null:
				cat_data.category_name = value

			if line_edit != null: line_edit.text = category_name 

## Only used to assign icon -> use default_btn.button_pressed to check if def
var is_default: bool = false:
	set(value):
		is_default = value
		default_btn.icon = get_theme_icon("GuiChecked" if value else "GuiUnchecked", "EditorIcons")




func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.keycode == KEY_ESCAPE:
		if line_edit.has_focus():
			line_edit.release_focus()



func _ready() -> void:
	_on_editor_settings_changed() 
	move_left_btn.set_button_icon(get_theme_icon("ArrowLeft", "EditorIcons"))
	move_right_btn.set_button_icon(get_theme_icon("ArrowRight", "EditorIcons")) 
	revert_btn.set_button_icon(get_theme_icon("Reload", "EditorIcons"))
	del_btn.set_button_icon(get_theme_icon("Remove", "EditorIcons"))
	revert_btn.hide()
	is_default = is_default # loads the icon

	settings.settings_changed.connect(_on_editor_settings_changed)
	del_btn.button_up.connect(_on_del_button_up)
	line_edit.text_changed.connect(_on_text_changed) 
	line_edit.focus_exited.connect(_on_line_edit_focus_exited)
	move_left_btn.button_up.connect(func() -> void: move_category_requested.emit(self, -1))
	move_right_btn.button_up.connect(func() -> void: move_category_requested.emit(self, 1))

	revert_btn.button_up.connect(
		func() -> void:
			line_edit.unedit()
			line_edit.release_focus()
			line_edit.text = category_name
			apply_btn.hide()
			default_btn.show()
			revert_btn.hide()
	)

	line_edit.editing_toggled.connect(
		func(toggled_on: bool) -> void: 
			revert_btn.tooltip_text = str("Revert to '", category_name, "'")
			revert_btn.visible = toggled_on
			_handle_state(STATES.EDITING if toggled_on else STATES.HOVER if is_hovered else STATES.IDLE)
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

	default_btn.toggled.connect(
		func(toggled_on: bool) -> void:
			set_default_category.emit(self, toggled_on)
			is_default = toggled_on
	)

	size = Vector2.ZERO
	if line_edit.text == "": 
		apply_btn.hide() 

	# data/cat_data are already fully loaded synchronously by this point, no need to await anything.
	_data_ready()



func _process(delta: float) -> void:
	var hovered_now := get_global_rect().has_point(get_global_mouse_position())
	if hovered_now != is_hovered:
		is_hovered = hovered_now
		if !line_edit.is_editing():
			_handle_state(STATES.HOVER if is_hovered else STATES.IDLE)



func _data_ready() -> void:
	if category_name != "":
		revert_btn.tooltip_text = str("Revert to '", category_name, "'")

	line_edit.text = category_name 
	if line_edit.text == "": 
		apply_btn.hide() 



func handle_name_state() -> void:
	var is_unchanged := line_edit.text == "" or line_edit.text == category_name

	apply_btn.visible = !is_unchanged
	default_btn.visible = is_unchanged



func check_name_conflict() -> bool:
	print(data.check_category_name_conflicts())
	return data.check_category_name_conflicts() if data != null else false



func apply_name(new_name: String) -> void:
	if new_name.is_empty():
		return

	new_name = new_name.replace(" ", "_")
	new_name.replace(" ", "_")

	var cat: Array = data.categories.duplicate()
	var cat_names = data.get_category_names()
	var def: String = data.default_category

	# New GLLogCategory
	if category_name == "":
		var new: GLCategoryData = GLCategoryData.new()
		new.category_name = new_name
		cat.append(new)
		cat_data = new

	# Existing GLLogCategory
	elif cat_names.has(category_name): 
		for i in range(cat.size()):
			if cat[i].category_name == category_name:
				cat[i].category_name = new_name 
				break

	data.categories = cat

	category_name = new_name
	line_edit.text = category_name
	log_category_changed.emit()
	line_edit.release_focus()
	apply_btn.hide()
	default_btn.show()



func _on_text_changed(new_text: String) -> void:
	# Handle disallowed chars
	if !new_text.is_valid_filename():
		var invalid_ch = ["<", ">", ":", "\"", "/", "\\", "|", "?", "*"]
		for c in invalid_ch:
			new_text = new_text.replace(c, "")
	new_text = new_text.replace(" ", "_")
	line_edit.text = new_text
	line_edit.caret_column = new_text.length()


	if new_text != category_name and category_name != "":
		line_edit.add_theme_stylebox_override("normal", sb_line_edit_invalid if check_name_conflict() else sb_line_edit_normal)



func _handle_state(state_to: STATES) -> void:
	var size_dur: float = 0.06
	var fade_dur: float = 0.03
	state_transition_id += 1
	var transition_id := state_transition_id
	state = state_to

	if state_to != STATES.IDLE:
		var fade_out := create_tween().set_parallel(true)
		fade_out.tween_property(move_left_btn, "modulate", Color.TRANSPARENT, size_dur)
		fade_out.tween_property(move_right_btn, "modulate", Color.TRANSPARENT, size_dur)
		fade_out.tween_property(apply_btn, "modulate", Color.TRANSPARENT, size_dur)
		fade_out.tween_property(del_btn, "modulate", Color.TRANSPARENT, size_dur)
		await fade_out.finished
		if transition_id != state_transition_id:
			return
		move_left_btn.hide()
		move_right_btn.hide()
		apply_btn.hide()
		del_btn.hide()

	match state_to:
		STATES.IDLE:
			custom_minimum_size = size
			var fade_out := create_tween().set_parallel(true)
			fade_out.tween_property(move_left_btn, "modulate", Color.TRANSPARENT, fade_dur)
			fade_out.tween_property(move_right_btn, "modulate", Color.TRANSPARENT, fade_dur)
			fade_out.tween_property(apply_btn, "modulate", Color.TRANSPARENT, fade_dur)
			fade_out.tween_property(del_btn, "modulate", Color.TRANSPARENT, fade_dur)
			await fade_out.finished
			if transition_id != state_transition_id:
				return
			
			move_left_btn.hide()
			move_right_btn.hide()
			apply_btn.hide()
			del_btn.hide()
			var resize := create_tween().set_parallel(true)
			resize.tween_property(self, "custom_minimum_size", IDLE_SIZE, size_dur)
			resize.tween_property(self, "custom_maximum_size", IDLE_SIZE, size_dur)

		STATES.HOVER:
			var is_edge_ordered: bool = false
			if move_right_btn.disabled or move_left_btn.disabled:
				is_edge_ordered = true
			var resize := create_tween().set_parallel(true)
			resize.tween_property(self, "custom_minimum_size", HOVER_EDGE_SIZE if is_edge_ordered else HOVER_SIZE, size_dur)
			resize.tween_property(self, "custom_maximum_size", HOVER_EDGE_SIZE if is_edge_ordered else HOVER_SIZE, size_dur) 
			await resize.finished
			if transition_id != state_transition_id:
				return

			var fade_in := create_tween().set_parallel(true)
			del_btn.modulate = Color.TRANSPARENT
			del_btn.show()
			fade_in.tween_property(del_btn, "modulate", Color.WHITE, fade_dur)
			if !move_left_btn.disabled:
				move_left_btn.modulate = Color.TRANSPARENT
				move_left_btn.show()
				fade_in.tween_property(move_left_btn, "modulate", Color.WHITE, fade_dur) 
			if !move_right_btn.disabled:
				move_right_btn.modulate = Color.TRANSPARENT
				move_right_btn.show()
				fade_in.tween_property(move_right_btn, "modulate", Color.WHITE, fade_dur) 


		STATES.EDITING:
			var resize := create_tween().set_parallel(true)
			resize.tween_property(self, "custom_minimum_size", EDITING_SIZE, size_dur)
			resize.tween_property(self, "custom_maximum_size", EDITING_SIZE, size_dur)
			await resize.finished
			if transition_id != state_transition_id:
				return

			apply_btn.show()
			var fade_in := create_tween()
			fade_in.tween_property(apply_btn, "modulate", Color.WHITE, fade_dur)



func _on_line_edit_focus_exited() -> void:
	if line_edit.text == category_name:
		apply_btn.hide()
		default_btn.show()



func _on_del_button_up() -> void: 
	queue_free()



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
