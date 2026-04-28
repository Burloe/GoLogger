class_name GLLogBrowser extends Control

signal log_file_added(log_file: GLLogFile) ## Emitted to Dock to update font colors


@onready var log_viewer: ScrollContainer = %LogViewer
@export var grid_columns: int = 10
var config: ConfigFile = ConfigFile.new()
var base_dir = config.get_value("settings", "base_directory")
const PATH = "user://gologger_data.ini" 
var categories: Array = [] # 2D array of category names and it's associated [GridContainer]
var cat_containers: Array[GridContainer] = []


func _ready() -> void:
	for child in get_children():
		child.queue_free()

	_load_base()


func _load_base() -> void:
	config.load(PATH)
	base_dir = config.get_value("settings", "base_directory")
	var cats = config.get_value("categories", "category_names") 
	
	categories.clear()
	for child in get_children():
		child.queue_free()

	for c in cats:

		if c.is_empty():
				continue

		var gc: GridContainer = GridContainer.new()
		gc.set_name(c)
		gc.columns = grid_columns
		add_child(gc)
		var n: Array = [c, gc]
		categories.append(n)



func load_logfiles(category_name: String) -> void:
	_load_base()

	for c in categories:
		if c.is_empty():
			continue

		var file_list: PackedStringArray = get_category_files(c)

		for file in file_list:
			var file_path := str(base_dir, category_name, "/", file)
			
			if not FileAccess.file_exists(file_path):
				#? Add broken file icon?
				continue

			var f = FileAccess.open(file_path, FileAccess.READ)
			var content = f.get_file_as_string(file_path)

			var lf: GLLogFile = GLLogFile.new()
			lf.category_name = c
			lf.file_name = file
			lf.lbl.text = content
			


			var _f = FileAccess.open(file_path, FileAccess.READ)
			if !_f: # ER
				#? Add broken file icon? 
				continue

			var lines : Array[String] = []
			while not _f.eof_reached():
				var _l = _f.get_line().strip_edges(false, true)
				if _l != "":
					lines.append(_l)


func get_category_files(category_name: String) -> PackedStringArray:
	config.load(PATH)
	base_dir = config.get_value("settings", "base_directory")
	categories = config.get_value("categories", "category_names") 
	
	if categories.is_empty():
		return []
	
	if base_dir.is_empty():
		return []

	var c_path: String = str(config.get_value("settings", "base_directory"), category_name, "/")

	var d := DirAccess.open(c_path)
	return d.get_files()

