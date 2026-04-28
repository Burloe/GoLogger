class_name GLLogFile extends Button

@onready var lbl: Label = %Label

var base_dir
var category_name: String = ""

var file_name: String = "":
	set(value):
		file_name = value
		if value != "":
			display_name = _get_name(file_name) 
 
var display_name: String = ""


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



func _get_year(year: int) -> String:
	return str("20", year)



func _get_month(month: int) -> String:
	var _m: Array[String] = [
		"N/A",
		"Jan",
		"Feb",
		"March",
		"April",
		"May",
		"June",
		"July",
		"Aug",
		"Sep",
		"Oct",
		"Nov",
		"Dec"
	]
	return _m[month]