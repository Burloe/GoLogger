@tool
class_name LogCategory extends PanelContainer

## Emitted when any property of the LogCategory changes to GologgerDock.gd so it can update its data accordingly.
signal log_category_changed(
	log_category: LogCategory,
	category_name: String,
	new_name: String,
	index: int,
	is_locked: bool,
	to_delete: bool
)
signal name_warning(toggle_on : bool, type : int)

## Emitted when a category is deleted so GoLoggerDock.gd can update the indices of the remaining categories.
signal category_deleted()

@onready var index_lbl: 	Label = 		%CategoryIndex
@onready var move_left_btn: Button = 	%MoveLeftButton
@onready var move_right_btn: Button = %MoveRightButton
@onready var lock_btn:	Button = 			%LockButton
@onready var line_edit: LineEdit = 		%CategoryNameLineEdit
@onready var del_btn:	Button = 				%DeleteButton
@onready var apply_btn: Button = 			%ApplyButton


const PATH = "user://GoLogger/settings.ini"
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
		if value:
			# Empty name
			if line_edit != null and line_edit.text == "":
				name_warning.emit(true, 0)
			# invalid name__
			elif line_edit != null and line_edit.text == category_name:
				name_warning.emit(true, 1)
		else:
			name_warning.emit(false, 0)

var is_locked : bool = false:
	set(value):
		is_locked = value
		log_category_changed.emit(self, category_name, "", index, is_locked, false)
		if lock_btn != null: lock_btn.button_pressed = is_locked
		if line_edit != null: line_edit.editable = !value
		if del_btn != null: del_btn.disabled = value
		if dock != null: dock.save_categories(true)

var category_name: String = "":
	set(value):
		if category_name != value:
			category_name = value
			if line_edit != null: line_edit.text = category_name
			if dock != null: dock.update_category_name(self, value)

var index : int = 0: ## This now simply determines the order of LogCategories in dock
	set(value):
		if value != index:
			log_category_changed.emit(self, category_name, "", value, is_locked, false)
		index = value
		move_left_btn.disabled = true if index == 0 else false
		move_right_btn.disabled = true if index == dock.category_container.get_child_count() - 1 else false
		if index_lbl != null:
			index_lbl.text = str(index)


func _ready() -> void:
	if Engine.is_editor_hint():
		config.load(PATH)

		del_btn.button_up.connect(_on_del_button_up)
		line_edit.text_changed.connect(_on_text_changed)
		move_left_btn.button_up.connect(move_log_category.bind(-1))
		move_right_btn.button_up.connect(move_log_category.bind(1))

		line_edit.text_submitted.connect(
			func(new_text: String) -> void:
				apply_name(new_text)
		)

		apply_btn.button_up.connect(
			func(new_text: String) -> void:
				apply_name(new_text)
		)

		lock_btn.toggled.connect(
			func(pressed: bool) -> void:
				is_locked = pressed
		)

		line_edit.text = category_name
		lock_btn.button_pressed = is_locked
		size = Vector2.ZERO
		if line_edit.text == "":
			invalid_name = true
			apply_btn.hide()
		else:
			invalid_name = false


func check_existing_conflicts(new_name : String) -> bool:
	config.load(PATH)
	var categories = config.get_value("categories", "category_names")
	for c_name in categories:
		if c_name == new_name and new_name != category_name:
			return true
		else:
			return false
	return false


func apply_name(new_name : String) -> void:
	if check_existing_conflicts(new_name):
		return

	log_category_changed.emit(self, category_name, new_name, index, is_locked, false)
	category_name = new_name
	line_edit.release_focus()
	apply_btn.hide()


func move_log_category(direction: int = 0) -> void:
	if direction == 0:
		return

	elif direction < 0:
		if index <= 0:
			return
		index -= 1 # log_category_changed is emitted in the setter
	else:
		if index >= dock.category_container.get_child_count() - 1:
			return
		index += 1 # log_category_changed is emitted in the setter


func _on_text_changed(new_text : String) -> void:
	if new_text == "" or check_existing_conflicts(new_text):
		if new_text != category_name:
			apply_btn.show()
			apply_btn.disabled = false
			invalid_name = false
		else:
			apply_btn.hide()
			apply_btn.disabled = true
			invalid_name = true
	else:
		apply_btn.show()
		apply_btn.disabled = false
		invalid_name = false

	if line_edit.get_caret_column() == line_edit.text.length() - 1:
		line_edit.set_caret_column(line_edit.text.length())
	else: line_edit.set_caret_column(line_edit.get_caret_column() + 1)


func _on_del_button_up() -> void:
	if dock != null:
		return

	print_rich("[color=878787][GoLogger] Category " + category_name + " deleted.")
	queue_free()
	dock.save_categories(true)
	category_deleted.emit()
