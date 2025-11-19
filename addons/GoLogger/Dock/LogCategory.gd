@tool
class_name LogCategory extends PanelContainer

## Emitted when any property of the LogCategory changes to GologgerDock.gd so it can update its data accordingly.
signal log_category_changed
signal log_category_deleted
signal request_log_deletion(log_category: LogCategory)
signal move_category_requested(log_category: LogCategory, direction : int)

## Emitted when a category is deleted so GoLoggerDock.gd can update the indices of the remaining categories.
signal category_deleted()

# @onready var index_lbl: 	Label = 		%CategoryIndex #Deprecated
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

var invalid_name : bool = false

var is_locked : bool = false:
	set(value):
		is_locked = value
		log_category_changed.emit()
		if lock_btn != null: lock_btn.button_pressed = is_locked
		if line_edit != null: line_edit.editable = !value
		if del_btn != null: del_btn.disabled = value
		# if dock != null: dock.save_categories(true)

var category_name: String = "":
	set(value):
		if category_name != value:
			category_name = value
			if line_edit != null: line_edit.text = category_name
			# if dock != null: dock.update_category_name(self, value)

var index : int = 0: ## This now simply determines the order of LogCategories in dock
	set(value):
		if value != index:
			log_category_changed.emit()
		index = value
		if move_left_btn  != null:
			move_left_btn.disabled = true if index == 0 else false
		if move_right_btn != null:
			move_right_btn.disabled = true if index == dock.category_container.get_child_count() - 1 else false
		# if index_lbl != null:
		# 	index_lbl.text = str(index)


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
			func() -> void:
				apply_name(line_edit.text)
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


func apply_name(new_name: String) -> void:
	var old_name := category_name
	var fin_name := get_unique_category_name(new_name, old_name)

	category_name = fin_name
	log_category_changed.emit()
	line_edit.release_focus()
	apply_btn.hide()

	if old_name == "":
		print_rich("[color=878787][GoLogger] Category <" + fin_name + "> created.")
	else:
		print_rich("[color=878787][GoLogger] Category <" + old_name + "> renamed to <" + fin_name + ">.")



func get_unique_category_name(name: String, ignore_name: String = "") -> String:
	config.load(PATH)
	var categories: Array = config.get_value("categories", "category_names", [])

	var base := name
	var suffix := 1

	var i := name.length() - 1
	while i >= 0 and name[i] >= "0" and name[i] <= "9":
		i -= 1

	if i < name.length() - 1:
		base = name.substr(0, i + 1)
		suffix = int(name.substr(i + 1, name.length() - (i + 1))) + 1

	var candidate := base
	if not has_conflict(candidate, ignore_name):
		return candidate

	while has_conflict(base + str(suffix), ignore_name):
		suffix += 1

	return base + str(suffix)


func has_conflict(candidate: String, ignore_name: String) -> bool:
	config.load(PATH)
	var categories: Array = config.get_value("categories", "category_names", [])
	for c in categories:
		if c != ignore_name and c == candidate:
			return true
	return false


func move_log_category(direction: int = 0) -> void:
	if direction == 0:
		return

	move_category_requested.emit(self, direction)

	# if direction < 0:
	# 	if index <= 0:
	# 		return
	# 	index -= 1 # log_category_changed is emitted in the setter
	# else:
	# 	if index >= dock.category_container.get_child_count() - 1:
	# 		return
	# 	index += 1 # log_category_changed is emitted in the setter


func _on_text_changed(new_text : String) -> void:
	if new_text == "" or has_conflict(new_text, ""):
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
	print_rich("[color=878787][GoLogger] Category <" + category_name + "> deleted.")
	request_log_deletion.emit(self)
