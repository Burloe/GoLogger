extends Control

## Disregard this script. Only exists to facilitate the showcase simulations in the example scene.

@onready var gamelog: Label = $LogContents/MarginContainer/ScrollContainer/VBoxContainer/HBoxContainer2/GAMElog
@onready var playerlog: Label = $LogContents/MarginContainer/ScrollContainer/VBoxContainer/HBoxContainer2/PLAYERlog
@onready var update_timer: Timer = $UpdateTimer

var rng := RandomNumberGenerator.new()


func _ready() -> void:
	randomize()
	GoLogger.session_status_changed.connect(_on_session_status_changed)
	update_timer.timeout.connect(_on_update_timer_timeout)
	for c in $VBoxContainer/Simulations/MarginContainer/VBoxContainer.get_children(): # Event Simulation buttons
		if c is Button:
			c.button_up.connect(_on_entry_sim_button_up.bind(c))
	set_log_text()

## Returns the last log in a directory. Call using the paths specified in [Log]. Example usage: [code]FileAccess.open(get_last_log(Log.GAME_PATH), FileAccess.READ[/code]
func get_last_log(path) -> String:
	var _dir = DirAccess.open(path) 
	if !_dir:
		var _err = DirAccess.get_open_error()
		if _err != OK:
			printerr("Showcase Error: Attempting to open directory (", path, ") to find .log -> Error[", _err, "]")
			return ""
	else: 
		var _files = _dir.get_files()
		return str(path + _files[_files.size() -1]) if _files.size() > 0 else ""
	return ""


func set_log_text() -> void:
	if GoLogger.current_game_file != "":
		var _g = FileAccess.open(GoLogger.current_game_file, FileAccess.READ)
		if !_g:
			var _err = FileAccess.get_open_error()
			if _err != OK:
				printerr("GoLogger Error: Attempting to read file contents in _on_update_timer_timeout() -> Error [", _err, "]")
		else:
			var _gc = _g.get_as_text()
			gamelog.text = _gc
		_g.close()
	else: gamelog.text = "No active session."
	
	if GoLogger.current_player_file != "":
		var _p = FileAccess.open(GoLogger.current_player_file, FileAccess.READ)
		if !_p:
			var _err = FileAccess.get_open_error()
			if _err != OK:
				printerr("GoLogger Error: Attempting to read file contents in _on_update_timer_timeout() -> Error [", _err, "]")
		else:
			var _pc = _p.get_as_text()
			playerlog.text = _pc
		_p.close()
	else: playerlog.text = "No active session."
	if gamelog.text.length() > playerlog.text.length():
		playerlog.size = gamelog.size
	if gamelog.size > playerlog.size: playerlog.size = gamelog.size
	if playerlog.size > gamelog.size: gamelog.size = playerlog.size


## Receives signal from [GoLogger] whenever a status is changed.
func _on_session_status_changed() -> void:
	set_log_text()


func _on_update_timer_timeout() -> void:
	set_log_text()
	$LogContents/MarginContainer/ScrollContainer/VBoxContainer/HBoxContainer/Label.text = str("Current game log file:\n", GoLogger.current_game_file)
	$LogContents/MarginContainer/ScrollContainer/VBoxContainer/HBoxContainer/Label2.text = str("Current player log file:\n", GoLogger.current_player_file)
 

## Buttons that simulates log entries.
func _on_entry_sim_button_up(btn : Button):
	var items : Array[String] = ["Pipe", "Handgun", "Gunpowder", "Uncased Bullets"]
	match btn.get_name():
		"Pickup":
			Log.entry(1, str("Picked up ", items[rng.randi_range(0, items.size() -1)], " x", rng.randi_range(1, 6), "."))
		"Combine": 
			Log.entry(1, str("Combined ItemA[Gunpowder] and itemB[Uncased Bullets] to create item[Handgun Ammo] x", rng.randi_range(1, 6), "."))
		"Discard": 
			Log.entry(1, str("Discarded [", items[rng.randi_range(0, items.size() -1)], "] x", randi_range(1, 6), "."))
		"Death": 
			Log.entry(1, "Player died")
		"Respawn": 
			Log.entry(1, str("Player respawned @", Vector2(randi_range(0, 512), randi_range(0, 512)), "."))
		"Load":
			Log.entry(0, str("Loaded GameSave#1 on Slot#", randi_range(1, 3), "."))
		"Save": 
			Log.entry(0, str("Saved GameSave#1 on Slot#", randi_range(1, 3), "."))
		"Exit": 
			Log.entry(0, "Exited game.")
		
	set_log_text()
