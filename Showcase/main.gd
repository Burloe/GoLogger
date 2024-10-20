extends Control

## Disregard this script. Only exists to facilitate the showcase simulations in the example scene.

@onready var gamelog: Label = $LogContents/MarginContainer/ScrollContainer/VBoxContainer/HBoxContainer2/GAMElog
@onready var playerlog: Label = $LogContents/MarginContainer/ScrollContainer/VBoxContainer/HBoxContainer2/PLAYERlog
@onready var update_timer: Timer = $UpdateTimer

var rng := RandomNumberGenerator.new()


func _ready() -> void:
	randomize()
	Log.session_status_changed.connect(_on_session_status_changed)
	update_timer.timeout.connect(_on_update_timer_timeout)
	for c in $VBoxContainer/Simulations/MarginContainer/VBoxContainer.get_children(): # Event Simulation buttons
		if c is Button:
			c.button_up.connect(_on_entry_sim_button_up.bind(c))
	set_log_text()


func set_log_text() -> void:
	if Log.current_game_file != "":
		var _g = FileAccess.open(Log.current_game_filepath, FileAccess.READ)
		if !_g:
			var _err = FileAccess.get_open_error()
			if _err != OK and !Log.disable_errors:
				printerr("GoLogger Error: Attempting to read file contents in _on_update_timer_timeout() -> ", Log.get_err_string(_err))
				return
		else:
			var _gc = _g.get_as_text()
			gamelog.text = _gc
		_g.close()
	else: gamelog.text = "No active session."
	
	if Log.current_player_file != "":
		var _p = FileAccess.open(Log.current_player_filepath, FileAccess.READ)
		if !_p:
			var _err = FileAccess.get_open_error()
			if _err != OK and !Log.disable_errors:
				printerr("GoLogger Error: Attempting to read file contents in _on_update_timer_timeout() -> ", Log.get_err_string(_err))
				return
		else:
			var _pc = _p.get_as_text()
			playerlog.text = _pc
		_p.close()
	else: playerlog.text = "No active session."


## Signal receiver: Updates log labels  whenever a status is changed.
func _on_session_status_changed() -> void:
	set_log_text()


func _on_update_timer_timeout() -> void:
	set_log_text()
	$LogContents/MarginContainer/ScrollContainer/VBoxContainer/HBoxContainer/Label.text = str("Current game log file:\n", Log.current_game_file)
	$LogContents/MarginContainer/ScrollContainer/VBoxContainer/HBoxContainer/Label2.text = str("Current player log file:\n", Log.current_player_file)
 

## Buttons that simulates log entries.
func _on_entry_sim_button_up(btn : Button):
	var items : Array[String] = ["Pipe", "Handgun", "Gunpowder", "Uncased Bullets"]
	match btn.get_name():
		"Pickup":
			Log.entry(str("Picked up ", items[rng.randi_range(0, items.size() -1)], " x", rng.randi_range(1, 6), "."), 1)
		"Combine": 
			Log.entry(str("Combined ItemA[Gunpowder] and itemB[Uncased Bullets] to create item[Handgun Ammo] x", rng.randi_range(1, 6), "."), 1)
		"Discard": 
			Log.entry(str("Discarded [", items[rng.randi_range(0, items.size() -1)], "] x", randi_range(1, 6), "."), 1)
		"Death": 
			Log.entry("Player died", 1 )
		"Respawn": 
			Log.entry(str("Player respawned @", Vector2(randi_range(0, 512), randi_range(0, 512)), "."), 1)
		"Load":
			Log.entry(str("Loaded GameSave#1 on Slot#", randi_range(1, 3), "."), 0)
		"Save": 
			Log.entry(str("Saved GameSave#1 on Slot#", randi_range(1, 3), "."), 0)
		"Exit": 
			Log.entry("Exited game.", 0)
			Log.stop_session()
			get_tree().quit()
	set_log_text()
