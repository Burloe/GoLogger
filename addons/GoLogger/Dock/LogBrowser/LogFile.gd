class_name GLLogFile extends Button

var category_name: String = ""
var file_name: String = "":
	set(value):
		file_name = value
		if value != "":
			assign_name()

var display_name: String = ""






func assign_name() -> void:
	var time: String
	var _name: String = str(get_time(int()))
	pass

 



func _get_name(name: String) -> String:
	var _timestamp: String = name.lstrip(str(category_name, "(")).rstrip(str(").log"))
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



func _get_date(name: String) -> String:
	var 

	return "s"



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