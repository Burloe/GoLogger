@tool
class_name LogCategory extends PanelContainer

## Emitted when a [LineEdit] category name is empty.
signal name_warning(toggle_on : bool, type : int)
## Emitted when the category index is changed to the GoLoggerDock.gd to check to reorder the categories and resolve conflicting indices.
signal index_changed(category: LogCategory, new_index: int)
## Emitted when a category is deleted so GoLoggerDock.gd can update the indices of the remaining categories.
signal category_deleted()

@onready var index_lbl: 	Label = 		%CategoryIndex 
@onready var move_left_btn: Button = 	%MoveLeftButton
@onready var move_right_btn: Button = 	%MoveRightButton
@onready var lock_btn:	Button = 		%LockButton
@onready var line_edit: LineEdit = 		%CategoryNameLineEdit
@onready var del_btn:	Button = 		%DeleteButton
@onready var apply_btn: Button = 		%ApplyButton 


@export var file_name: String = 	"null"
@export var file_path: String = 	"null"
@export var file_count: int = 		0
@export var entry_count: int = 		0
@export var category_name: String = "":
	set(value):
		if category_name != value:
			category_name = value
			if line_edit != null: line_edit.text = category_name
			if dock != null: dock.update_category_name(self, value)

@export var index : int = 0:
	set(value):
		index = value
		move_left_btn.disabled = true if index == 0 else false
		move_right_btn.disabled = true if index == dock.category_container.get_child_count() - 1 else false
		if index_lbl != null:
			index_lbl.text = str(index)

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
const PATH = "user://GoLogger/settings.ini"
var config = ConfigFile.new() 
var categories : Array 
var is_locked : bool = false:
	set(value): 
		is_locked = value
		if lock_btn != null: 	lock_btn.button_pressed = is_locked
		if line_edit != null: 	line_edit.editable = !value
		if del_btn != null: 	del_btn.disabled = value
		if dock != null: 		dock.save_categories(true)




func _ready() -> void:
	if Engine.is_editor_hint():
		config.load(PATH)
		categories = config.get_value("plugin", "categories", [["game", 0, "null", "null", 0, 0, true], ["player", 1, "null", "null", 0, 0, true]])
		del_btn.button_up.connect(_on_del_button_up)
		apply_btn.button_up.connect(_on_apply_button_up)
		line_edit.text_changed.connect(_on_text_changed)
		line_edit.text_submitted.connect(_on_text_submitted)
		move_left_btn.button_up.connect(_on_move_left_btn_up)
		move_right_btn.button_up.connect(_on_move_right_btn_up)
		lock_btn.toggled.connect(_on_lock_btn_toggled)
		line_edit.text = category_name
		lock_btn.button_pressed = is_locked
		size = Vector2.ZERO
		if line_edit.text == "":
			invalid_name = true
			apply_btn.disabled = true
		else: 
			invalid_name = false


func check_existing_conflicts(new_name : String) -> bool: 
	config.load(PATH)
	categories = config.get_value("plugin", "categories")
	for i in range(categories.size()):
		if categories[i][0] == name:
			return true
		else: return false
	return false


func apply_name(new_name : String) -> void:
	category_name = new_name
	line_edit.release_focus()
	apply_btn.disabled = true


func _on_move_left_btn_up() -> void:
	if index <= 0: return
	index_changed.emit(self, index - 1)


func _on_move_right_btn_up() -> void:
	if index >= dock.category_container.get_child_count() - 1: return
	index_changed.emit(self, index + 1)

func _on_text_changed(new_text : String) -> void:
	if new_text == "" or check_existing_conflicts(new_text):
		apply_btn.disabled = true
		invalid_name = true
	else:
		apply_btn.disabled = false
		invalid_name = false

	if line_edit.get_caret_column() == line_edit.text.length() - 1:
		line_edit.set_caret_column(line_edit.text.length())
	else: line_edit.set_caret_column(line_edit.get_caret_column() + 1)


func _on_apply_button_up() -> void:
	apply_name(line_edit.text)
	# index_changed.emit(self, index)


func _on_text_submitted(new_text : String) -> void:
	apply_name(new_text)

 
func _on_lock_btn_toggled(toggled : bool) -> void:
	is_locked = toggled
	

func _on_del_button_up() -> void:
	if dock != null: 
		queue_free() 
		dock.save_categories(true) 
		category_deleted.emit()
var current_health
var max_health
		
func _on_player_take_damage(amount) -> void:
	Log.entry("Player's current health: " + str(current_health) + " / " + str(max_health), 1)
