@tool
extends Panel

## Index [Label] node. Indicates the order of the log categories as displayed in the dock.
@onready var ilbl 		: Label = 		$MarginContainer/VBoxContainer/HBoxContainer/iLabel
## Lock [Button] node. Toggles [param is_locked].
@onready var lock_btn 	: Button = 		$MarginContainer/VBoxContainer/HBoxContainer/LockButton
## [LineEdit] node. Used to indicate and rename this log category.
@onready var line_edit 	: LineEdit = 	$MarginContainer/VBoxContainer/LineEdit
## Delete [Button] node. Deletes this log category
@onready var del_btn 	: Button = 		$MarginContainer/VBoxContainer/HBoxContainer2/DeleteButton
## Apply [Button] node. Applied the submitted [LineEdit] text.
@onready var apply_btn 	: Button = 		$MarginContainer/VBoxContainer/HBoxContainer2/ApplyButton

var dock : TabContainer ## Dock root
## Flags whether or not this log is locked. I.e. safe from being deleted or renamed.
var is_locked : bool = false:
	set(value):
		# print(str(category_name, " > is_locked = ", is_locked, ". new_value = ", value))
		is_locked = value
		if lock_btn != null: lock_btn.button_pressed = is_locked
		if line_edit != null: 	line_edit.editable = !value
		if del_btn != null: 	del_btn.disabled = value
		if dock != null: 		dock.save_categories(true)

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



func _ready() -> void:
	if Engine.is_editor_hint():
		del_btn.button_up.connect(_on_del_button_up)
		apply_btn.button_up.connect(_on_text_submitted)
		line_edit.text_changed.connect(_on_text_changed)
		line_edit.text_submitted.connect(_on_text_submitted)
		lock_btn.toggled.connect(_on_lock_btn_toggled)
		line_edit.text = category_name
		ilbl.text = str(index)
		lock_btn.button_pressed = is_locked
		apply_btn.disabled = true


## Updates the index label when deleting a category.
func refresh_index_label(idx : int) -> void:
	ilbl.text = str(idx)


## Enables/disables the Apply button when the [LineEdit] text changes IF
## the new text is either "" or the current category name.
func _on_text_changed(new_text : String) -> void:
	if new_text != category_name or new_text != "":
		apply_btn.disabled = false
	else:
		apply_btn.disabled = true
	line_edit.set_caret_column(line_edit.text.length())


## Applies a new category name when [LineEdit]'s text is submitted either 
## by using the Apply button or pressing the Enter key while [LineEdit] 
## is focused. 
func _on_text_submitted(new_text : String) -> void:
	# Conflict checking is done in category_name's set()
	category_name = new_text
	line_edit.release_focus()
	apply_btn.disabled = true


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