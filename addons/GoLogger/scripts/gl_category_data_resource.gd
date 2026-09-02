@tool
class_name GLCategoryData extends Resource

@export var category_name: String = "":
	set(value):
		category_name = value.to_lower()
@export var file_name: String = ""
@export var file_path: String = ""
@export var file_count: int = 0
@export var entry_count: int = 0


## Returns true if a category_name has been applied properly to initialize the category.
func is_valid() -> bool:
	return !category_name.is_empty()