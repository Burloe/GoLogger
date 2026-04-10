@tool
class_name LogCategory extends PanelContainer

## Emitted when any property of the LogCategory changes to GologgerDock.gd so it can update its data accordingly.
signal log_category_changed(log_category: LogCategory, is_name_change: bool, old_name: String)
signal log_category_deleted
signal request_log_deletion(log_category: LogCategory)
signal move_category_requested(log_category: LogCategory, direction : int)

## Emitted when a category is deleted so GoLoggerDock.gd can update the indices of the remaining categories.
signal category_deleted()

@onready var move_left_btn: Button = 				%MoveLeftButton
@onready var move_right_btn: Button = 			%MoveRightButton
@onready var lock_btn:	Button = 						%LockButton
@onready var default_checkbox: CheckBox = 	%DefaultCheckBox
@onready var line_edit: LineEdit = 					%CategoryNameLineEdit
@onready var del_btn:	Button = 							%DeleteButton
@onready var apply_btn: Button = 						%ApplyButton

@onready var settings = EditorInterface.get_editor_settings()
@onready var editor_base_col: Color = settings.get("interface/theme/base_color")
@onready var editor_accent_col: Color = settings.get("interface/theme/accent_color")
var sb_panel_round_base: StyleBoxFlat = preload("uid://cywnobmluy31i")
var sb_panel_round_base_accent_border: StyleBoxFlat = preload("uid://qbiwr8hnwf5n")
var sb_line_edit_normal: StyleBoxFlat = preload("uid://pue22dsifmfd")
var sb_line_edit_highlight: StyleBoxFlat = preload("uid://dl1ay0wubtp2m")
var sb_line_edit_invalid: StyleBoxFlat = preload("uid://sqhht0mdddoi")

const PATH = "user://gologger_data.ini"
var config = ConfigFile.new()
var dock : TabContainer:
	set(value):
		dock = value
		if dock != null:
			if move_right_btn != null:
				move_right_btn.disabled = true if dock.category_container.get_child_count() >= index - 1 else false

var invalid_name : bool = false:
	set(value):
		invalid_name = value
		if !is_locked:
			line_edit.add_theme_stylebox_override(
				"normal",
				sb_line_edit_invalid if value else sb_line_edit_normal
			)

var is_locked : bool = false:
	set(value):
		is_locked = value
		log_category_changed.emit(self, false, "")
		add_theme_stylebox_override("panel", sb_panel_round_base_accent_border if is_locked else sb_panel_round_base)
		if lock_btn != null: lock_btn.button_pressed = is_locked
		if line_edit != null: line_edit.editable = !value
		if del_btn != null: del_btn.disabled = value

var category_name: String = "":
	set(value):
		config.load(PATH)

		if category_name != value:
			category_name = value
			if line_edit != null: line_edit.text = category_name

var index : int = 0: ## This now simply determines the order of LogCategories in dock
	set(value):
		if value != index:
			log_category_changed.emit(self, false, "")
		index = value
		if move_left_btn  != null:
			move_left_btn.disabled = true if index == 0 else false
		if move_right_btn != null:
			move_right_btn.disabled = true if index == dock.category_container.get_child_count() - 1 else false


func _ready() -> void:
	if Engine.is_editor_hint():
		config.load(PATH)

		# settings.settings_changed.connect(_on_editor_settings_changed)
		_on_editor_settings_changed()

		del_btn.button_up.connect(_on_del_button_up)
		# line_edit.text_changed.connect(_on_text_changed)
		move_left_btn.button_up.connect(move_log_category.bind(-1))
		move_right_btn.button_up.connect(move_log_category.bind(1))


		line_edit.text_submitted.connect(
			func(new_text: String) -> void:
				if !check_name_conflict():
					apply_name(new_text)
				else:
					line_edit.text = category_name
					handle_name_state()
		)

		line_edit.text_changed.connect(
			func(new_text: String) -> void:
				handle_name_state()
		)

		line_edit.mouse_entered.connect(
			func() -> void:
				line_edit.add_theme_stylebox_override("normal", sb_line_edit_highlight)
		)

		line_edit.mouse_exited.connect(
			func() -> void:
				line_edit.add_theme_stylebox_override("normal", sb_line_edit_normal)
		)

		apply_btn.button_up.connect(
			func() -> void:
				if !check_name_conflict():
					apply_name(line_edit.text)
		)

		lock_btn.toggled.connect(
			func(pressed: bool) -> void:
				is_locked = pressed
		)

		default_checkbox.toggled.connect(
			func(pressed: bool) -> void:
				dock.set_default_category(self, pressed)
		)

		line_edit.text = category_name
		lock_btn.button_pressed = is_locked
		size = Vector2.ZERO
		if line_edit.text == "":
			invalid_name = true
			apply_btn.hide()
		else:
			invalid_name = false

		_sync_stylebox_colors()



func handle_name_state() -> void:
	if line_edit.text == "" or line_edit.text == category_name:
		apply_btn.hide()
		apply_btn.disabled = true
		default_checkbox.show()
		invalid_name = true
		print(1)

	else:
		apply_btn.show()
		apply_btn.disabled = false
		default_checkbox.hide()
		invalid_name = true
		print(2)

	if check_name_conflict():
		apply_btn.disabled = true


func check_name_conflict() -> bool:
	config.load(PATH)
	return config.get_value("categories", "category_names", []).has(line_edit.text)


# Add red border to line edit when name is invalid?
# Need to refactor. Instead of updating categories according to dock when the game is ran. It needs to update on every "log_category_changed()" signal emission.

func apply_name(new_name: String) -> void:
	config.load(PATH)

	var cat: Array = config.get_value("categories", "category_names", []).duplicate()
	var def: String = config.get_value("categories", "default_category", "")
	var old_name: String = category_name

	if old_name == "": # Is new LogCategory
		cat.append(new_name)

	if cat.has(old_name) and old_name != "": # Is existing LogCategory
		for c in cat.size():
			if cat[c] == old_name:
				cat[c] = new_name
				printerr(c, " +++ ", cat)
				break

	if old_name == def:
		config.set_value("categories", "default_category", new_name)

	config.set_value("categories", "category_names", cat)
	printerr(config.get_value("categories", "category_names"))
	config.save(PATH)

	if category_name == "":
		print_rich("[color=878787][GoLogger] Category <" + new_name + "> created.")
	else:
		print_rich("[color=878787][GoLogger] Category <" + category_name + "> renamed to <" + new_name + ">.")

	category_name = new_name
	line_edit.text = new_name
	log_category_changed.emit(self, true, new_name)
	line_edit.release_focus()
	apply_btn.hide()
	default_checkbox.show()


func move_log_category(direction: int = 0) -> void:
	if direction == 0:
		return

	move_category_requested.emit(self, direction)



# func _on_text_changed(new_text : String) -> void:
# 	if new_text == "" or has_conflict(new_text, ""):
# 		if new_text != category_name:
# 			apply_btn.show()
# 			apply_btn.disabled = false
# 			invalid_name = false
# 		else:
# 			apply_btn.hide()
# 			apply_btn.disabled = true
# 			invalid_name = true
# 	else:
# 		apply_btn.show()
# 		apply_btn.disabled = false
# 		invalid_name = false

# 	if line_edit.get_caret_column() == line_edit.text.length() - 1:
# 		line_edit.set_caret_column(line_edit.text.length())
# 	else: line_edit.set_caret_column(line_edit.get_caret_column() + 1)


func _on_del_button_up() -> void:
	print_rich("[color=878787][GoLogger] Category <" + category_name + "> deleted.")
	request_log_deletion.emit(self)


func _on_editor_settings_changed() -> void:
	settings = EditorInterface.get_editor_settings()
	editor_base_col = settings.get_setting("interface/theme/base_color")
	editor_accent_col = settings.get_setting("interface/theme/accent_color")
	_sync_stylebox_colors()


func _sync_stylebox_colors():
	var editor_theme = EditorInterface.get_editor_theme()
	editor_base_col = settings.get("interface/theme/base_color")
	editor_accent_col = settings.get("interface/theme/accent_color")
	var accent_contrast_l = editor_accent_col.lerp(Color.WHITE, settings.get("interface/theme/contrast"))
	var accent_contrast_d = editor_accent_col.lerp(Color.BLACK, settings.get("interface/theme/contrast"))
	var base_contrast_l = editor_base_col.lerp(Color.WHITE, settings.get("interface/theme/contrast"))
	var base_contrast_d = editor_base_col.lerp(Color.BLACK, settings.get("interface/theme/contrast"))
