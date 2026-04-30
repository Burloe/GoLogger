@tool
extends Button

@onready var lbl: Label = null

# var sb := preload("uid://xy4uummjvhgu")
# var lbl_sett := preload("uid://c8w51vy1pqjq8")
var file_ico := preload("uid://chfkhfc65al6t")
var file_broken_ico := preload("uid://bt0xt83bipjft")

var base_dir
var category_name: String = ""

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

@export var placeholder_name: String = str("17:22:53\nApril 27\n2026") 



func _ready() -> void:
	text = display_name if display_name != "" else placeholder_name



func _get_name(file_name: String) -> String:
	var _timestamp: String = file_name.lstrip(str(category_name, "(")).rstrip(str(").log"))
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



func set_icon(is_valid: bool) -> void:
	icon = file_ico if is_valid else file_broken_ico