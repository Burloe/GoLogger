@tool
class_name GLLogBrowser extends Control

signal log_file_added(log_file: GLLogFile) ## Emitted to Dock to update font colors

@onready var category_tab_container = %CategoryTabContainer
@onready var log_viewer: Panel = %LogViewer
@onready var lw_title_lbl: Label = %ViewerTitleLabel
@onready var lw_close_btn: Button = %ViewerCloseButton
@onready var lw_font_size_slider: HSlider = %ViewerFontSizeHSlider
@onready var lw_contents_lbl: Label = %ContentLabel

@export var grid_columns: int = 10
const PATH = "user://gologger_data.ini"
var cont_lbl_sett = preload("uid://cqn5x8cb7vjy3")
var config: ConfigFile = ConfigFile.new()
var base_dir = ""
var categories: Array = [] # 2D array of category names and it's associated [GridContainer]
var cat_containers: Array[GridContainer] = []


func _ready() -> void:
	_load_log_browser()
	lw_close_btn.button_up.connect(_on_log_viewer_close_button_up)
	log_viewer.hide()



func _load_log_browser() -> void:
	var e := config.load(PATH)
	if e != OK: printerr("Failed to load config: ", error_string(e))
	base_dir = config.get_value("settings", "base_directory", "")
	var cats = config.get_value("categories", "category_names", [])

	if base_dir == "":
		printerr("Failed to load Base Directory!")
	if cats.is_empty():
		printerr("Failed to load Categories!")
	# print(base_dir, "   ", cats)

	categories.clear()
	for child in category_tab_container.get_children():
		child.queue_free()

	for c in cats:

		if c == "":
				continue
		
		var gc: GridContainer = GridContainer.new()
		gc.set_name(c)
		gc.columns = grid_columns
		category_tab_container.add_child(gc)
		gc.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		gc.size_flags_vertical   = Control.SIZE_EXPAND_FILL
		# print(gc)
		var n: Array = [c, gc]
		categories.append(n)
		_load_logfiles(c)



func _load_logfiles(category_name: String) -> void: 
	var file_list: PackedStringArray = get_category_files(category_name)
	# print(file_list)

	for file in file_list:
		var file_path: String = str(base_dir.path_join(str(category_name, "_logs")).path_join(file), "/")
		
		if not FileAccess.file_exists(file_path):
			#? Add broken file icon? 
			continue

		var f = FileAccess.open(file_path, FileAccess.READ)
		var content = f.get_file_as_string(file_path)

		var lf: GLLogFile = GLLogFile.new()
		lf.category_name = category_name
		lf.file_name = file

		for c in categories:
			# print("category_namae: ", category_name, "   iterated category: ", c, "    saved array category: ", c)
			if c[0] != category_name:
				continue
			
			c[1].add_child(lf)
			lf.button_up.connect(_on_log_file_button_up.bind(category_name, file, content))
			log_file_added.emit(lf)

		lw_contents_lbl.text = content



func get_category_files(category_name: String) -> PackedStringArray:
	if categories.is_empty():
		return []	
	if base_dir == "":
		return []

	var c_path: String = str(base_dir.path_join(category_name), "_logs/")

	var d := DirAccess.open(c_path)
	if d != null:
		return d.get_files()

	printerr("Failed to open category path: ", c_path)
	return []



func _on_log_file_button_up(category_name: String, file_name: String, content: String) -> void:
	lw_title_lbl.text = str(category_name, " - ", file_name)
	lw_contents_lbl.text = content
	log_viewer.show()


func _on_log_viewer_close_button_up() -> void:
	log_viewer.hide()