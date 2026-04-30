@tool
class_name GLLogBrowser extends Control

signal log_file_added(log_file: Button) ## Emitted to Dock to update font colors

@onready var category_tab_container = %CategoryTabContainer
@onready var fake_topbar: VBoxContainer = %FakeTopBar
@onready var log_viewer: Panel = %LogViewer
@onready var lw_title_lbl: Label = %ViewerTitleLabel
@onready var lw_refresh_btn: Button = %ViewerRefreshButton
@onready var lw_close_btn: Button = %ViewerCloseButton
@onready var lw_font_size_slider: VSlider = %ViewerFontSizeVSlider
@onready var lw_contents_lbl: Label = %ContentLabel
@onready var ctrl_padding: Control = %Padding

@export var grid_columns: int = 10
const PATH = "user://gologger_data.ini"
var log_file_btn := preload("uid://bq7nahsc5aca7")
var cont_lbl_sett = preload("uid://cqn5x8cb7vjy3")
var config: ConfigFile = ConfigFile.new()
var base_dir = ""
var categories: Array = [] # 2D array of category names and it's associated [GridContainer]
var cat_containers: Array[GridContainer] = []

enum BrowserState {
	LIST_VIEW,
	LOG_VIEW
}
var state: BrowserState = BrowserState.LIST_VIEW



func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT and event.is_released():
		if state == BrowserState.LOG_VIEW:
			_toggle_view()




func _ready() -> void:
	_load_log_browser(true)
	lw_close_btn.button_up.connect(_on_button_up.bind(lw_close_btn))
	lw_refresh_btn.button_up.connect(_on_button_up.bind(lw_refresh_btn))
	lw_font_size_slider.value_changed.connect(on_slider_value_changed.bind(lw_font_size_slider))
	lw_font_size_slider.value = lw_contents_lbl.label_settings.font_size 
	
	category_tab_container.show()
	log_viewer.hide()
	lw_refresh_btn.show()
	lw_close_btn.hide()
	lw_font_size_slider.hide()
	ctrl_padding.show()
	state = BrowserState.LIST_VIEW 




func _load_log_browser(is_initializing: bool = false) -> void:
	var e := config.load(PATH)
	if e != OK: printerr("Failed to load config: ", error_string(e))
	base_dir = config.get_value("settings", "base_directory", "")
	var cats = config.get_value("categories", "category_names", [])

	if base_dir == "":
		printerr("Failed to load Base Directory!")
	if cats.is_empty():
		printerr("Failed to load Categories!") 

	categories.clear()

	for child in category_tab_container.get_children():
		child.queue_free()
	
	if !is_initializing:
		lw_refresh_btn.disabled = true
		category_tab_container.hide()
		fake_topbar.show()
		await get_tree().create_timer(0.1).timeout 
		lw_refresh_btn.disabled = false
		category_tab_container.show()
		fake_topbar.hide()

	for c in cats:

		if c == "":
				continue
		
		var gc: GridContainer = GridContainer.new()
		gc.columns = grid_columns
		category_tab_container.add_child(gc)
		gc.set_name(c)
		gc.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		gc.size_flags_vertical   = Control.SIZE_EXPAND_FILL 
		var n: Array = [c, gc]
		categories.append(n)
		_load_logfiles(c)



func _load_logfiles(category_name: String) -> void: 
	var file_list: PackedStringArray = get_category_files(category_name) 

	for file in file_list:
		var file_path: String = str(base_dir.path_join(str(category_name, "_logs")).path_join(file), "/")
		
		if not FileAccess.file_exists(file_path):
			#? Add broken file icon? 
			continue

		var f = FileAccess.open(file_path, FileAccess.READ)
		var content = f.get_file_as_string(file_path)

		var lf: Button = log_file_btn.instantiate() as Button
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



func _toggle_view() -> void:
	fake_topbar.hide()
	match state:
		BrowserState.LIST_VIEW:
			category_tab_container.hide()
			log_viewer.show()
			lw_refresh_btn.hide()
			lw_close_btn.show()
			lw_font_size_slider.show()
			ctrl_padding.hide()
			state = BrowserState.LOG_VIEW
		BrowserState.LOG_VIEW:
			category_tab_container.show()
			log_viewer.hide()
			lw_refresh_btn.show()
			lw_close_btn.hide()
			lw_font_size_slider.hide()
			ctrl_padding.show()
			state = BrowserState.LIST_VIEW



func _on_log_file_button_up(category_name: String, file_name: String, content: String) -> void:
	lw_title_lbl.text = str(category_name, " - ", file_name)
	lw_contents_lbl.text = content
	_toggle_view() 



func _on_button_up(btn: Button) -> void:
	match btn:
		lw_close_btn:
			_toggle_view()  
		lw_refresh_btn:
			_load_log_browser()



func on_slider_value_changed(value: int, slider: VSlider) -> void:
	match slider:
		lw_font_size_slider:
			cont_lbl_sett.font_size = value