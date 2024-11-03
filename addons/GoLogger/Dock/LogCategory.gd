@tool
extends Panel

@onready var ilbl : Label = $MarginContainer/VBoxContainer/HBoxContainer/iLabel
@onready var lock_btn : Button = $MarginContainer/VBoxContainer/HBoxContainer/LockButton
@onready var line_edit : LineEdit = $MarginContainer/VBoxContainer/LineEdit
@onready var del_btn : Button = $MarginContainer/VBoxContainer/DeleteButton
var dock : TabContainer ## Dock root
var is_locked : bool = false:
	set(value):
		print(str(category_name, " > is_locked = ", is_locked, ". new_value = ", value))
		is_locked = value
		if lock_btn != null: lock_btn.button_pressed = is_locked
		if line_edit != null: 	line_edit.editable = !value
		if del_btn != null: 	del_btn.disabled = value
		if dock != null: 		dock.save_categories(true)

@export var category_name : String = "":
	set(value):
		if category_name != value and value.length() <= dock.max_name_length:
			category_name = value
			if line_edit != null: line_edit.text = category_name
			if dock != null: dock.update_category_name(self, value)

@export var index : int = 0:
	set(value):
		index = value
		if ilbl != null:
			ilbl.text = str(value)



func _ready() -> void:
	if Engine.is_editor_hint():
		del_btn.button_up.connect(_on_del_button_up)
		line_edit.text_changed.connect(_on_text_changed)
		line_edit.text_submitted.connect(_on_text_submitted)
		lock_btn.toggled.connect(_on_lock_btn_toggled)
		line_edit.text = category_name
		ilbl.text = str(index)
		lock_btn.button_pressed = is_locked


func refresh_index_label(idx : int) -> void:
	ilbl.text = str(idx)


func _on_text_changed(new_text : String) -> void:
	category_name = new_text # category_name's set() performs conflict checks
	line_edit.set_caret_column(line_edit.text.length())


func _on_text_submitted(new_text : String) -> void:
	line_edit.release_focus()


func _on_lock_btn_toggled(toggled : bool) -> void:
	is_locked = toggled
	
	

func _on_del_button_up() -> void:
	if dock != null: 
		queue_free() 
		dock.save_categories(true)
		dock.update_indices(true)