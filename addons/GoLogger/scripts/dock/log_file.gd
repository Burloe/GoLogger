@tool
class_name GLLogFile extends Button

@onready var lbl: Label = null

var file_ico := preload("uid://chfkhfc65al6t")
var file_broken_ico := preload("uid://cntk5aesu05sa")
var sb_selected := preload("uid://bcprdy8psyd0k")
var sb_unselected := preload("uid://xy4uummjvhgu")

var selected: bool = false:
	set(value):
		selected = value
		add_theme_stylebox_override("normal", sb_selected if value else sb_unselected)
		add_theme_stylebox_override("pressed", sb_selected if value else sb_unselected)
		add_theme_stylebox_override("hover", sb_selected if value else sb_unselected)
		add_theme_stylebox_override("hover_pressed", sb_selected if value else sb_unselected)
var base_dir
var category_name: String = ""
var file_path: String = ""
var file_name: String = "":
	set(value):
		file_name = value
		if value != "":
			
			display_name = _get_name(file_name)
			get_file_content()
 
var display_name: String = "":
	set(value):
		display_name = value
		if lbl != null:
			lbl.text = value

var file_contents: String = "":
	set(value):
		file_contents = value

@export var placeholder_name: String = str("17:22:53\nApril 27\n2026")
@export var display_name_char_limit: int = 18



func _ready() -> void:
	text = display_name if display_name != "" else placeholder_name
	mouse_entered.connect(get_file_content)



func get_file_content() -> void:
	if !is_file_valid():
		return
	
	var f := FileAccess.open(file_path, FileAccess.READ)
	var content: String = f.get_file_as_string(file_path)
	var err := f.get_open_error()
	tooltip_text = str("Failed to open file! Error[", f.get_open_error(), "]") if err != OK else file_name
	f.close()
	file_contents = content



func is_file_valid() -> bool:	
	var is_valid: bool = FileAccess.file_exists(file_path)

	if file_name.is_empty() or !file_name.ends_with(".log"):
		print(file_name, "   - ", file_contents)
		is_valid = false
	
	assign_icon(is_valid)	
	disabled = !is_valid
	return is_valid



func is_gl_name(file_name_to_check: String) -> bool: 
		if file_name_to_check.is_empty() or category_name.is_empty():
				return false

		var prefix := category_name + "("
		if !file_name_to_check.begins_with(prefix) or !file_name_to_check.ends_with(").log"):
				return false

		# Get YYMMDD_HHMMSS
		var stamp_len := file_name_to_check.length() - prefix.length() - 5
		if stamp_len != 13:
				return false

		var stamp := file_name_to_check.substr(prefix.length(), stamp_len)
		if stamp.substr(6, 1) != "_":
				return false

		var date_part := stamp.substr(0, 6)
		var time_part := stamp.substr(7, 6)

		if !date_part.is_valid_int() or !time_part.is_valid_int():
				return false

		return true 



func assign_icon(is_valid: bool) -> void:
	icon = file_ico if is_valid else file_broken_ico



func get_date() -> String:
	if file_name.is_empty():
		return ""

	if !file_name.begins_with(category_name):
		return ""

	return file_name.lstrip(str(category_name, "(")).rstrip(str(").log"))	



func _get_name(_f_name: String) -> String:
	if !_f_name.ends_with(".log"):
		return _f_name
	if !_f_name.begins_with(category_name):
		return _f_name

	var _name: String =""
	if !_f_name.begins_with(category_name):
		var _n = _f_name.left(display_name_char_limit) + "-.log"
		return _n


	var _timestamp: String = _f_name.lstrip(str(category_name, "(")).rstrip(str(").log"))
	var _splits: Array = _timestamp.split("_") 

	var fin_time: String = str(
		_splits[1].substr(0, 2), ":", 
		_splits[1].substr(2, 2), ":", 
		_splits[1].substr(4, 2), "\n"
	)

	var fin_date: String = str(
		_get_month(_splits[0].substr(2, 2)), 
		_splits[0].substr(4, 2), "\n", 
		_get_year(_splits[0].substr(0, 2))
	)
	tooltip_text = _f_name
	return fin_time + fin_date



func _get_year(year: String) -> String:
	return str("20", year)



func _get_month(month: String) -> String:
	var i := month.to_int()
	var _m: Array[String] = [
		"N/A",
		"Jan ",
		"Feb ",
		"March ",
		"April ",
		"May ",
		"June ",
		"July ",
		"Aug ",
		"Sep ",
		"Oct ",
		"Nov ",
		"Dec "
	]
	return _m[i]
