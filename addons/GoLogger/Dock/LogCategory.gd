@tool
extends Panel


@onready var line_edit : LineEdit = $MarginContainer/VBoxContainer/LineEdit
@onready var del_btn : Button = $MarginContainer/VBoxContainer/DeleteButton
var dock : Panel ## Dock root

@export var cat_name : String = "":
	set(value):
		if value.length() <= 20:
			dock.change_category_name(value)
			cat_name = value
@export var index : int = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if Engine.is_editor_hint():
		del_btn.button_up.connect(_on_del_button_up)
		line_edit.text_changed.connect(_on_text_changed)
		line_edit.text = cat_name
		



func _on_text_changed(new_text : String) -> void:
	cat_name = new_text



func _on_del_button_up() -> void:
	dock.remove_category(cat_name)
	queue_free() 