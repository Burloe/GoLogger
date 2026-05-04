@tool
class_name GLLogFile extends Button

@onready var lbl: Label = null

var file_ico := preload("uid://chfkhfc65al6t")
var file_broken_ico := preload("uid://cntk5aesu05sa")

var base_dir
var category_name: String = ""
var file_path: String = ""
var file_name: String = "":
	set(value):
		file_name = value
		if value != "":
			display_name = _get_name(file_name) 
 
var display_name: String = "":
	set(value):
		display_name = value
		if lbl != null:
			lbl.text = value

var file_contents: String = ""

@export var placeholder_name: String = str("17:22:53\nApril 27\n2026")
@export var display_name_char_limit: int = 18



func _ready() -> void:
	text = display_name if display_name != "" else placeholder_name
	mouse_entered.connect(get_file_content)


func get_file_content() -> void:
	if !is_file_valid():
		assign_icon(false)
		return
	
	var f := FileAccess.open(file_path, FileAccess.READ)
	var content: String = f.get_file_as_string(file_path)
	var err := f.get_open_error()
	tooltip_text = str("Failed to open file! Error[", f.get_open_error(), "]") if err != OK else file_name
	assign_icon(!content.is_empty())
	f.close()
	
	file_contents = content



func is_file_valid() -> bool:	
	var is_valid := FileAccess.file_exists(file_path) 
	if file_name.is_empty() or !file_name.ends_with(".log"):
		is_valid = false
	return is_valid



func _get_name(_f_name: String) -> String:
	if !_f_name.ends_with(".log"):
		assign_icon(false)
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



func assign_icon(is_valid: bool) -> void:
	disabled = !is_valid
	icon = file_ico if is_valid else file_broken_ico