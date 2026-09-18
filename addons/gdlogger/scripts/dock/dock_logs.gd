@tool
extends HBoxContainer


signal request_save(source: String) ## Emitted to dock.gd. "source" is purely for debugging to see what emitted.
signal request_categories_save
signal request_theme_colors 
# signal category_created(category: GLLogCategory)
signal selected_category_updated(new_selected: String)

@onready var settings_tab: Control = %SettingsTab
@onready var category_panel: HBoxContainer = %CategoryPanel
@onready var add_category_btn: Button = %AddCategoryButton
@onready var category_container: GridContainer = %CategoryGridContainer

@onready var polling_timer: Timer = %PollingTimer
@onready var popup_panel: PopupPanel = %LogFilePanelPopup

@onready var log_settings_btn: Button = %LogSettingsButton
@onready var log_settings_popup: PopupPanel = %LogsSettingsPanelPopup
@onready var log_settings_content: HBoxContainer = %LogSettingsContentHBox
@onready var open_w_os_btn: Button = %LBOpenWOSButton
@onready var colorcode_btn: Button = %ColorCodeButton
@onready var sort_mode_btn: Button = %LBSortModeButton

@onready var margin_container: MarginContainer = %LBMarginContainer
@onready var file_container: GridContainer = %FileGridContainer 
@onready var reload_btn: Button = %LBReloadButton


@export var data: GLData = null
var inspector: EditorInspector

const GRID_SEPARATION = 8
const GRID_GROUP_SORT_SEPARATION = 24
var log_file_btn := preload("uid://bq7nahsc5aca7")
var cont_lbl_sett = preload("uid://cqn5x8cb7vjy3")
var ico_colorcode_on := preload("uid://blyvrbbwfn67h")
var ico_colorcode_off := preload("uid://buxaemplfttdx")
var ico_sort_new = 	preload("uid://dvjgbc6hibv5m")
var ico_sort_old = 	preload("uid://bljitewxdnvuh") 
var category_scene = preload("uid://c3n416c5fajm5") 

var is_active: bool = true
var is_shutting_down: bool = false
var is_reloading: bool = false
var is_content_hovered: bool = false
var _default_setting_in_progress: bool = false  
var _column_update_pending: bool = false 

var min_cell_width: int = 140
var base_dir = ""
var hovered_logfile: GLLogFile
var categories: Array = [] # [["game", gameGridContainer], ["player", playerGridContainer]]
var cat_containers: Array[GridContainer] = []
var grid_conts: Array[GridContainer] = []
var log_files: Array[GLLogFile] = []
var current_category: String = "":
	set(value):
		if value != current_category:
			current_category = value
			# selected_category_updated.emit(value)
			load_log_files()
		
var cur_logfile: GLLogFile = null:
	set(value):
		cur_logfile = value 

var open_log_with_os: bool = false:
	set(value):
		open_log_with_os = value
		open_w_os_btn.icon = get_theme_icon("GuiChecked" if value else "GuiUnchecked", "EditorIcons")
		open_w_os_btn.tooltip_text = "Open logs using OS" if value else "Open logs within Editor"
		data.open_logs_with_os = value

var cur_sort: SortModes = SortModes.NEW: 
	set(value):
		cur_sort = value
		var modes := ["\nNew first", "\nOld first"]
		sort_mode_btn.tooltip_text = str("Sorting by:", modes[value])
		var icons := [ico_sort_new, ico_sort_old]
		sort_mode_btn.icon = icons[value]
		data.browser_sort = value

var theme_colors: Dictionary = {}

enum LimitMethod { ## Index 3 is a SEPERATOR and should not be used.
	ENTRY_COUNT,
	SESSION_TIMER,
	BOTH,
	SEPERATOR,
	NONE
}
enum EntryCountAction {
	OVERWRITE_ENTRIES,
	RESTART,
	STOP
}
enum SessionTimerAction {
	RESTART,
	STOP
}
enum SortModes {
	NEW,
	OLD
}


func _on_log_settings_button_up() -> void:
	log_settings_popup.visible = !log_settings_popup.visible
	log_settings_popup.initial_position = Window.WINDOW_INITIAL_POSITION_ABSOLUTE
	log_settings_popup.position = Vector2i(log_settings_btn.get_screen_position() + Vector2(48, -8))

	if log_settings_popup.visible:
		log_settings_popup.popup()



func _ready() -> void:
	_connect_unique(add_category_btn.button_up, _add_category) 
	for log_c in category_container.get_children():
		log_c.queue_free()

	settings_tab.colorcode_changed.connect(_on_colorcode_changed)
	reload_btn.button_up.connect(load_log_files)
	polling_timer.timeout.connect(load_log_files)

	log_settings_btn.button_up.connect(_on_log_settings_button_up)
	open_w_os_btn.button_up.connect(func() -> void: open_log_with_os = !open_log_with_os)
	colorcode_btn.button_up.connect(
		func() -> void: 
			data.colorcode_dates = !data.colorcode_dates
			colorcode_btn.set_button_icon(ico_colorcode_on if data.colorcode_dates else ico_colorcode_off)
	)
	sort_mode_btn.button_up.connect(
		func() -> void:
			cur_sort = (cur_sort + 1) % 2
			load_log_files()
	) 
	resized.connect(_update_columns)
	
	inspector = EditorInspector.new()
	inspector.edit(ResourceLoader.load("uid://cqn5x8cb7vjy3"))
	inspector.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	inspector.size_flags_vertical = Control.SIZE_EXPAND_FILL 
	open_log_with_os = open_log_with_os # loads the icon


#region Categories

func initialize_categories() -> void:	## Called by dock.gd after data is initialized.
	ensure_default_category()
	
	for cat in data.categories.duplicate():
		if cat.category_name.is_empty():
			continue
		_add_category(cat.category_name)

	if !data.default_category.is_empty():
		for cat in category_container.get_children():
			if cat is GLLogCategory and cat.category_name == data.default_category and cat.default_btn != null:
				cat.default_btn.button_pressed = true
				break



func _connect_unique(signal_obj: Signal, callback: Callable) -> void:
	if signal_obj.is_connected(callback):
		signal_obj.disconnect(callback)
	signal_obj.connect(callback)



func _add_category(_name: String = ""): ## _name only applicable at loading
	var _n = category_scene.instantiate() as GLLogCategory 
	var low_name: String = _name.to_lower()
	_n.category_name = low_name
	category_container.add_child(_n)
	_n.data = data
	for c: GLCategoryData in data.categories:
		if c.category_name == _name:
			_n.cat_data = c
			break
	_n._data_ready()
	
	_n.log_category_changed.connect(func() -> void: request_categories_save.emit()) 
	_n.set_default_category.connect(_on_set_default_category)
	_n.move_category_requested.connect(_on_category_move_requested)
	_n.select_btn.toggled.connect(
		func(toggle_on) -> void: 
			if toggle_on: 
				current_category = _n.category_name
				for c: GLLogCategory in category_container.get_children():
					if c.category_name != current_category:
						c.select_btn.button_pressed = false
	)
	_n.tree_exited.connect(_on_category_tree_exited)
	
	if !low_name.is_empty():
		_n.default_btn.button_pressed = data.default_category == low_name
	else:	
		_n.line_edit.grab_focus()
	
	handle_category_mov_button_state() 



func ensure_default_category() -> void:
	var c_names := []
	for c in data.categories:
		c_names.append(c.category_name)
	if c_names.is_empty() and data.default_category != "" or !c_names.has(data.default_category):
		data.default_category = ""



func _on_category_move_requested(category: GLLogCategory, direction: int) -> void:
	var cats: Array = category_container.get_children()
	var from: int = category.get_index()
	var to: int = from
	var opposite_dir = 1 if direction == -1 else -1

	for c in cats:
		c.move_left_btn.disabled = true
		c.move_right_btn.disabled = true
		c.move_left_btn.add_theme_color_override("icon_disabled_color", c.move_left_btn.get_theme_color("icon_normal_color"))
		c.move_right_btn.add_theme_color_override("icon_disabled_color", c.move_right_btn.get_theme_color("icon_normal_color"))
	category_container.get_child(0).move_left_btn.add_theme_color_override("icon_disabled_color", Color.TRANSPARENT)
	category_container.get_child(category_container.get_child_count() -1).move_right_btn.add_theme_color_override("icon_disabled_color", Color.TRANSPARENT)

	to += direction

	if to < 0 or to >= cats.size():
		return

	var cols: int = max(1, category_container.columns)
	var h_sep: float = float(category_container.get_theme_constant("h_separation"))
	var v_sep: float = float(category_container.get_theme_constant("v_separation"))
	var step_x: float = category.size.x + h_sep
	var step_y: float = category.size.y + v_sep 
	var from_row: int = int(from / cols)
	var from_col: int = from % cols
	var to_row: int = int(to / cols)
	var to_col: int = to % cols

	var delta := Vector2(
		float(to_col - from_col) * step_x,
		float(to_row - from_row) * step_y
	)

	var other: GLLogCategory = cats[to]

	var tween := create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC).set_parallel()
	category.offset_transform_enabled = true
	other.offset_transform_enabled = true

	tween.tween_property(category, "offset_transform_position", delta, 0.05)
	tween.tween_property(other, "offset_transform_position", -delta, 0.05)
	await tween.finished 

	category_container.move_child(category, to)
	category.offset_transform_position = Vector2.ZERO
	category.offset_transform_enabled = false
	cats[to].offset_transform_position = Vector2.ZERO
	cats[to].offset_transform_enabled = false
	request_categories_save.emit()
	for c in cats:
		c.move_left_btn.disabled = false
		c.move_right_btn.disabled = false
		c.move_left_btn.add_theme_color_override("icon_disabled_color", Color.TRANSPARENT)
		c.move_right_btn.add_theme_color_override("icon_disabled_color", Color.TRANSPARENT)
	category_container.get_child(0).move_left_btn.disabled = true
	category_container.get_child(category_container.get_child_count() - 1).move_right_btn.disabled = true



func _on_category_tree_exited() -> void: 
	if is_shutting_down:
		return

	handle_category_mov_button_state()
	request_categories_save.emit()



func _on_set_default_category(cat: GLLogCategory, set_status: bool) -> void:
	if _default_setting_in_progress:
		return
	
	_default_setting_in_progress = true
	
	for log_c in category_container.get_children():
		if log_c is GLLogCategory and log_c.default_btn != null:
			if log_c != cat:
				log_c.default_btn.button_pressed = false

	if set_status and cat.default_btn != null:
		cat.default_btn.button_pressed = true
	
	data.default_category = cat.category_name if set_status else "" 
	_default_setting_in_progress = false



func handle_category_mov_button_state() -> void:
	for i in range(category_container.get_child_count()):
		var category = category_container.get_child(i)
		category.move_left_btn.disabled = (i == 0)
		category.move_right_btn.disabled = (i == category_container.get_child_count() - 1)



func _check_conflict_name(cat_obj: GLLogCategory, new_name: String) -> bool:
	for log_c in category_container.get_children():
		if log_c == cat_obj:
			continue
		elif log_c.category_name == new_name:
			if name == "": return false
			return true
	return false

#endregion



#region Log Files

func load_log_files(is_initializing: bool = false) -> void: ## Used to both initialize and reload the file list
		if not is_active or is_reloading:
				return 

		if data != null:
				base_dir = data.base_dir

		if base_dir == "":
				printerr("GDLogger: Failed to load Base Directory!")
				return

		if current_category == "" and !data.categories.is_empty() and data.categories[0] != null:
				for cat in data.categories:
						if cat.category_name == data.default_category:
								current_category = cat.category_name
								for log_cat in category_container.get_children():
										if log_cat.category_name == current_category:
												log_cat.select_btn.button_pressed = true
								break

		if current_category == "":
				_clear_all_log_files()
				return

		var target_files: Array = _sort_file_list(current_category)

		var current_file_names: Array = []
		for lf in log_files:
				if is_instance_valid(lf):
						current_file_names.append(lf.file_name)

		if !is_initializing and current_file_names == target_files:
				return

		is_reloading = true
		_reconcile_log_files(target_files, current_category)

		await get_tree().physics_frame
		_update_columns(is_initializing) 
		is_reloading = false



func _clear_all_log_files() -> void:
		for child in file_container.get_children():
				file_container.remove_child(child)
				child.queue_free()
		log_files.clear()



func _reconcile_log_files(target_files: Array, category_name: String) -> void:
		var existing_by_name: Dictionary = {}
		for lf in log_files:
				if is_instance_valid(lf):
						existing_by_name[lf.file_name] = lf

		var target_set: Dictionary = {}
		for file_name in target_files:
				target_set[file_name] = true

		for file_name in existing_by_name.keys():
				if not target_set.has(file_name):
						var lf: GLLogFile = existing_by_name[file_name]
						if is_instance_valid(lf):
								file_container.remove_child(lf)
								lf.queue_free()
						existing_by_name.erase(file_name)

		var updated_log_files: Array[GLLogFile] = []
		var colorcode: Color = Color.BLACK
		var used_cols: Array[Color] = []
		var prev_file: String = ""

		for i in range(target_files.size()):
				var file_name: String = str(target_files[i])
				var lf: GLLogFile = null

				if existing_by_name.has(file_name):
						lf = existing_by_name[file_name]
						if lf.get_index() != i:
								file_container.move_child(lf, i)
				else:
						lf = _create_logfile_obj(category_name, file_name)
						if lf == null:
								continue
						file_container.add_child(lf)
						file_container.move_child(lf, i)
						lf.button_up.connect(_open_log_file.bind(lf))

				if data.colorcode_dates:
						var new_c := _get_logfile_color(used_cols)
						var pdate: String = prev_file.lstrip(str(category_name, "(")).rstrip(").log")
						var cdate: String = file_name.lstrip(str(category_name, "(")).rstrip(").log")
						if prev_file.is_empty() or !cdate.begins_with(pdate.substr(0, 6)):
								colorcode = _get_logfile_color(used_cols)
								used_cols.append(colorcode)
						lf.add_theme_color_override("font_color", colorcode)
						lf.add_theme_color_override("font_hover_color", colorcode.lightened(0.2))
						lf.add_theme_color_override("font_hover_pressed_color", colorcode.darkened(0.2))
				else:
						lf.add_theme_color_override("font_color", theme_colors["font"]["normal"])
						lf.add_theme_color_override("font_hover_color", theme_colors["font"]["hover"])
						lf.add_theme_color_override("font_pressed_color", theme_colors["font"]["normal"])

				updated_log_files.append(lf)
				prev_file = file_name

		log_files = updated_log_files



func _create_logfile_obj(category_name: String, file_name: String) -> GLLogFile:
		var file_path: String = str(base_dir.path_join(str(category_name, "_logs")).path_join(file_name), "/")
		
		if not FileAccess.file_exists(file_path):
				return null

		var f := FileAccess.open(file_path, FileAccess.READ)
		if f == null:
				return null
				
		var content := f.get_file_as_string(file_path)
		var has_error := f.get_open_error() != OK
		f.close()
				
		var lf: GLLogFile = log_file_btn.instantiate() as GLLogFile
		lf.category_name = category_name
		lf.file_name = file_name
		lf.file_path = file_path
		lf.file_contents = content
		lf.assign_icon(true)
		lf.mouse_entered.connect(func() -> void: hovered_logfile = lf)
		lf.mouse_exited.connect(func() -> void: hovered_logfile = null)
		lf.connect_to_popup(popup_panel)

		if hovered_logfile != null and hovered_logfile.file_name == file_name and hovered_logfile.category_name == category_name:
				lf.mouse_entered.emit()

		if has_error or !lf.is_file_valid():
				lf.assign_icon(false)

		return lf


func _get_category_files(category_name: String) -> PackedStringArray:
		if base_dir == "" or category_name.is_empty():
				return []

		var c_path: String = str(base_dir.path_join(category_name), "_logs/")
		var d := DirAccess.open(c_path)
		if d != null:
				return d.get_files()

		return []



func _on_colorcode_changed() -> void:
	var files := file_container.get_children() 
	var colorcode: Color = Color.BLACK
	var used_cols: Array[Color]= []
	var prev_file: GLLogFile = null
	var test = [0, [1, [2, 3]]]

	if files.is_empty():
		return

	for cur_file: GLLogFile in files:
		var file_name = cur_file.file_name
		if data.colorcode_dates:
			var pdate: String = prev_file.date_stamp if prev_file else ""

			if !prev_file or !cur_file.date_stamp.contains(prev_file.date_stamp):
					colorcode = _get_logfile_color(used_cols)
					used_cols.append(colorcode)
			cur_file.add_theme_color_override("font_color", 							colorcode)
			cur_file.add_theme_color_override("font_hover_color", 				colorcode.lightened(0.2))
			cur_file.add_theme_color_override("font_hover_pressed_color", colorcode.darkened(0.2))
		else:
			cur_file.add_theme_color_override("font_color", 				theme_colors["font"]["normal"])
			cur_file.add_theme_color_override("font_hover_color", 	theme_colors["font"]["hover"])
			cur_file.add_theme_color_override("font_pressed_color", theme_colors["font"]["normal"])
		prev_file = cur_file



func _sort_file_list(category_name: String) -> Array:
	var file_list: PackedStringArray = _get_category_files(category_name) 
	var fin_list: Array = [] 
	
	if cur_sort in [SortModes.NEW, SortModes.OLD]:
		var stray_files: PackedStringArray = []
		for file in file_list:
			if !file.ends_with(".log") or file.is_empty():
				continue

			if file.begins_with(category_name):
				fin_list.append(file)
			else:
				stray_files.append(file)

		if cur_sort == SortModes.NEW:
			fin_list.reverse()
	
		if !stray_files.is_empty():
			for file in stray_files:
				fin_list.append(file)

	return fin_list



func _open_log_file(log_file: GLLogFile) -> void:
	if !log_file.file_name.ends_with(".log"):
		return
	
	if open_log_with_os:
		var abs_path = ProjectSettings.globalize_path(log_file.file_path)
		OS.shell_open(abs_path)
		return

	popup_panel.content = log_file.file_contents
	popup_panel.popup()
	
	var fin_time: String = ""
	var fin_date: String = ""
	if log_file.is_gl_name(log_file.file_name):
		var _timestamp: String = log_file.file_name.lstrip(str(log_file.category_name, "(")).rstrip(").log")
		var _splits: Array = _timestamp.split("_") 
		var _m: Array[String] = [
			"N/A",
			" Jan ",
			" Feb ",
			" March ",
			" April ",
			" May ",
			" June ",
			" July ",
			" Aug ",
			" Sep ",
			" Oct ",
			" Nov ",
			" Dec "
		]

		fin_time = str(
			_splits[1].substr(0, 2), ":", 
			_splits[1].substr(2, 2), ":", 
			_splits[1].substr(4, 2)	
		)
		
		fin_date = str(
			_splits[0].substr(4, 2),
			_m[int(_splits[0].substr(2, 2))],
			str(20, (_splits[0].substr(0, 2)))
		)
	for lf: GLLogFile in log_files:
		if lf != log_file and lf.selected:
			lf.selected = false 
	
	log_file.selected = true 
	popup_panel.title = str(log_file.category_name.capitalize(), fin_date, " - ", fin_time, " | ", log_file.file_name)
	cur_logfile = log_file 



func _get_logfile_color(used_colors: Array[Color]) -> Color:
	var rng := RandomNumberGenerator.new()
	var c := Color.BLACK
	
	while c == Color.BLACK or c.get_luminance() <= 0.6 and c.get_luminance() >= 0.85:
		c = Color(rng.randf_range(0.6, 1.0), rng.randf_range(0.6, 1.0), rng.randf_range(0.6, 1.0), 0.8) 
		for col in used_colors:
			while c.is_equal_approx(col):
				c = Color(rng.randf_range(0.6, 1.0), rng.randf_range(0.6, 1.0), rng.randf_range(0.6, 1.0), 0.8)
	return c



func _update_columns(is_initializing: bool = false) -> void:
	if min_cell_width <= 0 or !file_container or !is_active: 
		file_container.columns = 999
		return

	var first_log_file: GLLogFile = null
	for log_file in log_files:
		if is_instance_valid(log_file) and not log_file.is_queued_for_deletion():
			first_log_file = log_file
			break

	if !first_log_file:
		file_container.columns = 999
		return

	var cell_width: int = first_log_file.size.x + file_container.get_theme_constant("h_separation")
	var col: int = 1
	if is_initializing:
		col = max(1, int(margin_container.size.x / cell_width)) 
	else:
		col = max(1, int(file_container.size.x / cell_width)) 
	# print("[Col: ", col, "]    [Size.X: ", margin_container.size.x if is_initializing else file_container.size.x, "]    [is_init: ", is_initializing, "]")
	file_container.columns = col

#endregion