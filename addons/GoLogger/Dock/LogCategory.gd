@tool
extends Panel

@onready var ilbl : Label = $MarginContainer/VBoxContainer/Label 
@onready var line_edit : LineEdit = $MarginContainer/VBoxContainer/LineEdit
@onready var del_btn : Button = $MarginContainer/VBoxContainer/DeleteButton
var dock : TabContainer ## Dock root


@export var category_name : String = "":
	set(value):
		if value.length() <= 20:
			if dock != null: dock.update_category_name(self, value)
			category_name = value
			if line_edit != null: line_edit.text = category_name
			
@export var index : int = 0:
	set(value):
		print(str("UPDATING FROM ", index, " TO ", value))
		index = value
		ilbl.text = str(value)
		print(str("UPDATED LABEL NOW SAYS = ", ilbl.text))

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if Engine.is_editor_hint():
		del_btn.button_up.connect(_on_del_button_up)
		line_edit.text_changed.connect(_on_text_changed)
		line_edit.text_submitted.connect(_on_text_submitted)
		line_edit.text = category_name
		ilbl.text = str(index)


func update_index_label(idx : int) -> void:
	ilbl.text = str(idx)


func _on_text_changed(new_text : String) -> void:
	dock._t = str("\n", index)
	dock.update_category_name(self, new_text)

func _on_text_submitted(new_text : String) -> void:
	line_edit.release_focus()


func _on_del_button_up() -> void: 
	dock.remove_category(category_name)
	queue_free() 