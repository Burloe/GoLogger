@tool
class_name GLLogFile extends Button

@onready var lbl: Label = null

var sb := preload("uid://xy4uummjvhgu")
var file_ico := preload("uid://chfkhfc65al6t")

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

var placeholder_name: String = str("17:22:53\nApril 27\n2026")

func _ready() -> void:
	custom_minimum_size = Vector2(100, 52)
	add_theme_stylebox_override("normal", sb)
	add_theme_stylebox_override("hover", sb)
	add_theme_stylebox_override("pressed", sb)

	var hbox: HBoxContainer = HBoxContainer.new()
	add_child(hbox)
	hbox.size_flags_horizontal = Control.SIZE_EXPAND
	hbox.size_flags_vertical = Control.SIZE_EXPAND

	var trect := TextureRect.new()
	trect.texture = file_ico
	trect.stretch_mode = TextureRect.STRETCH_KEEP
	trect.custom_minimum_size = Vector2(16, 16)
	hbox.add_child(trect)
	trect.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	trect.size_flags_vertical = Control.SIZE_SHRINK_CENTER

	lbl = Label.new()
	lbl.custom_minimum_size = Vector2(60, 0)
	autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	var lset := LabelSettings.new()
	lset.font_size = 10
	lbl.label_settings = lset
	lbl.text = display_name if display_name != "" else placeholder_name
	hbox.add_child(lbl)





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