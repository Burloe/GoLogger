@tool
class_name GLLogFile extends Button


@export var fallback_name: String = str("<NA>")
@export var date_stamp: String = ""
@export var time_stamp: String = ""

const DISPLAY_NAME_CHAR_LIMIT: int = 18

var sb_selected := 			preload("uid://bo0ob3gd3g7a")
var sb_unselected := 		preload("uid://cobusnqe7lb31")

var selected: bool = false:
	set(value):
		selected = value
		add_theme_stylebox_override("normal", 				sb_selected if value else sb_unselected)
		add_theme_stylebox_override("pressed", 				sb_selected if value else sb_unselected)
		add_theme_stylebox_override("hover", 					sb_selected if value else sb_unselected)
		add_theme_stylebox_override("hover_pressed", 	sb_selected if value else sb_unselected)
var base_dir
var category_name: String = ""
var file_path: String = ""
var file_name: String = "":
	set(value):
		file_name = value
		fallback_name = value
		if value != "" and is_gl_name(value):
			display_name = _get_name(file_name)
			get_file_content()
			var dt: String = value.lstrip(str(category_name, "(")).rstrip(").log")
			date_stamp = dt.split("_", false, 2)[0]
			time_stamp = dt.split("_", false, 2)[1]
			is_non_gl_log = is_gl_name(value) 


var is_non_gl_log: bool = false
var display_name: String = ""

var file_contents: String = ""




func _ready() -> void:
	text = display_name if display_name != "" else fallback_name
	# mouse_entered.connect(get_file_content)
	expand_icon = true
	add_theme_constant_override("icon_max_width", 32)


func connect_to_popup(pop: PopupPanel) -> void:
	if pop: pop.popup_hide.connect(func() -> void: button_pressed = false)


func get_file_content() -> void:
	if !is_file_valid():
		return
	
	var f := FileAccess.open(file_path, FileAccess.READ)
	var content: String = f.get_file_as_string(file_path)
	var err := f.get_open_error()
	f.close()
	file_contents = content



func is_file_valid() -> bool:	
	var is_valid: bool = FileAccess.file_exists(file_path)

	if file_name.is_empty() or !file_name.ends_with(".log"):
		is_valid = false
		
	disabled = !is_valid
	return is_valid



func is_gl_name(file_name_to_check: String) -> bool: 
	if file_name_to_check.is_empty() or category_name.is_empty():
			return false

	var prefix := category_name + "("
	if !file_name_to_check.begins_with(prefix) or !file_name_to_check.ends_with(").log"):
			return false

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
		var _n = _f_name.left(DISPLAY_NAME_CHAR_LIMIT) + "-.log"
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
