@tool
extends PanelContainer

## Emitted when a [LineEdit] category name is empty.
signal name_warning(toggle_on : bool, type : int)

## Index [Label] node. Indicates the order of the log categories as displayed in the dock.
@onready var ilbl 		: Label = 		%IndexLabel
## Lock [Button] node. Toggles [param is_locked].
@onready var lock_btn 	: Button = 		%LockButton
## [LineEdit] node. Used to indicate and rename this log category.
@onready var line_edit 	: LineEdit = 	%CategoryNameLineEdit
## Delete [Button] node. Deletes this log category
@onready var del_btn 	: Button = 		%DeleteButton
## Apply [Button] node. Applied the submitted [LineEdit] text.
@onready var apply_btn 	: Button = 		%ApplyButton 
var dock : TabContainer ## Dock root

## Flags if the name is invalid or not. If true, emit 
## [signal name_warning] to Dock to display warning.
var invalid_name : bool = false:
	set(value):
		invalid_name = value
		if value:
			# Empty name
			if line_edit != null and line_edit.text == "":
				name_warning.emit(true, 0)
			# invalid name
			elif line_edit != null and line_edit.text == category_name:
				name_warning.emit(true, 1)
		else:
			name_warning.emit(false, 0)

## The prefix name of this log. 
@export var category_name : String = "":
	set(value):
		if category_name != value:
			category_name = value
			if line_edit != null: line_edit.text = category_name
			if dock != null: dock.update_category_name(self, value)


## Index/order of categories as they're displayed in the dock.
@export var index : int = 0:
	set(value):
		index = value
		if ilbl != null:
			ilbl.text = str(value)
## File name of the .log file of the active session.
@export var file_name : String = "null"
## The filepath to the .log file of the active session.
@export var file_path : String = "null"
## The file count of the active session.
@export var file_count : int = 0
## The entry count of the active session.
@export var entry_count : int = 0

const PATH = "user://GoLogger/settings.ini"
var config = ConfigFile.new()
var categories : Array 

var pause : bool = false

## Flags whether or not this log is locked. I.e. safe from being deleted or renamed.
var is_locked : bool = false:
	set(value):
		# print(str(category_name, " > is_locked = ", is_locked, ". new_value = ", value))
		is_locked = value
		if lock_btn != null: 	lock_btn.button_pressed = is_locked
		if line_edit != null: 	line_edit.editable = !value
		if del_btn != null: 	del_btn.disabled = value
		if dock != null: 		dock.save_categories(true)


func _ready() -> void:
	if Engine.is_editor_hint():
		config.load(PATH)
		categories = config.get_value("plugin", "categories")
		del_btn.button_up.connect(_on_del_button_up)
		apply_btn.button_up.connect(_on_apply_button_up)
		line_edit.text_changed.connect(_on_text_changed)
		line_edit.text_submitted.connect(_on_text_submitted)
		lock_btn.toggled.connect(_on_lock_btn_toggled)
		line_edit.text = category_name
		ilbl.text = str(index)
		lock_btn.button_pressed = is_locked
		size = Vector2.ZERO
		if line_edit.text == "":
			invalid_name = true
			apply_btn.disabled = true
		else: 
			invalid_name = false


## Updates the index label when deleting a category.
func refresh_index_label(idx : int) -> void:
	ilbl.text = str(idx)

## Checks the name against existing category names in the saved
## categories settings.ini file.
func check_existing_conflicts(name : String) -> bool: 
	config.load(PATH)
	categories = config.get_value("plugin", "categories")

	for i in range(categories.size()):
		if categories[i][0] == name:
			return true
		else: return false
	return false


func apply_name(name : String) -> void:
	category_name = name
	line_edit.release_focus()
	apply_btn.disabled = true
	pass


## Enables/disables the Apply button when the [LineEdit] text changes IF
## the new text is either "" or the current category name.
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


## Applies a new category name when [LineEdit]'s text is submitted either 
## by using the Apply button or pressing the Enter key while [LineEdit] 
## is focused. 
func _on_text_submitted(new_text : String) -> void:
	apply_name(new_text)


## Locks this category from being removed or renamed.
func _on_lock_btn_toggled(toggled : bool) -> void:
	is_locked = toggled
	
	
## Queue free's this category element, save the new categories(deferred) 
## and then update the indicies.
func _on_del_button_up() -> void:
	if dock != null: 
		queue_free() 
		dock.save_categories(true)
		dock.update_indices(true) 


