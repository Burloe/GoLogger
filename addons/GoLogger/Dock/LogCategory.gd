@tool
extends Panel

@onready var ilbl : Label = $MarginContainer/VBoxContainer/Label 
@onready var line_edit : LineEdit = $MarginContainer/VBoxContainer/LineEdit
@onready var del_btn : Button = $MarginContainer/VBoxContainer/DeleteButton
var dock : TabContainer ## Dock root



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

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if Engine.is_editor_hint():
		del_btn.button_up.connect(_on_del_button_up)
		line_edit.text_changed.connect(_on_text_changed)
		line_edit.text_submitted.connect(_on_text_submitted)
		line_edit.text = category_name
		ilbl.text = str(index)


func refresh_index_label(idx : int) -> void:
	ilbl.text = str(idx)


func _on_text_changed(new_text : String) -> void:
	category_name = new_text # category_name's set() performs conflict checks
	line_edit.set_caret_column(line_edit.text.length())


func _on_text_submitted(new_text : String) -> void:
	line_edit.release_focus()


func _on_del_button_up() -> void:
	if dock != null: 
		queue_free() 
		dock.save_categories(true)
		dock.update_indices(true)