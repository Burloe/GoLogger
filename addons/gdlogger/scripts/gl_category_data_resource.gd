@tool
class_name GLCategoryData extends Resource

@export var category_name: String = "":
	set(value):
		category_name = value.to_lower()
@export var category_path: String = ""
@export var file_name: String = ""
@export var file_path: String = ""
@export var file_count: int = 0
@export var entry_count: int = 0
@export var is_default: bool = false
