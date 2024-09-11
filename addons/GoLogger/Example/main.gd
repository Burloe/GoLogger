extends Control

## Disregard this script. Only exists to facilitate the showcase simulations in the example scene. 

@onready var label: Label = $LogContents/MarginContainer/ScrollContainer/Label
@onready var session_status_lbl: RichTextLabel = %SessionStatusLbl

var rng := RandomNumberGenerator.new()
const FILE = "res://GoLogger/game.log"


func _ready() -> void:
	randomize()
	GoLogger.session_toggle.connect(_on_session_toggle)
	for c in $VBoxContainer/Simulations/MarginContainer/VBoxContainer.get_children():
		if c is Button:
			c.button_up.connect(_on_button_up.bind(c))
	for c in $VBoxContainer/LogActions/MarginContainer/VBoxContainer/HBoxContainer.get_children():
		if c is Button:
			c.button_up.connect(_on_session_button_up.bind(c))
	
	var _file = FileAccess.open(FILE, FileAccess.READ)
	var _content = _file.get_as_text()
	label.text = _content
	if GoLogger.log_session: session_status_lbl.text = "[center]Session Status: [color=green] Logging"
	else: session_status_lbl.text = "[center]Session Status: [color=red] Not logging"

func _on_session_toggle(toggle : bool):
	if toggle: session_status_lbl.text = "[center]Session Status: [color=green] Logging"
	else: session_status_lbl.text = "[center]Session Status: [color=red] Not logging"


func _on_session_button_up(btn : Button):
	match btn.get_name():
		"Start": Log.start_session()
		"Stop": Log.stop_session()
		"Clear": Log.clear_session()
	var _file = FileAccess.open(FILE, FileAccess.READ)
	var _content = _file.get_as_text()
	label.text = _content

func _on_button_up(btn : Button):
	var items : Array[String] = [
		"Pipe",
		"Handgun",
		"Gunpowder",
		"Uncased Bullets"
	]
	match btn.get_name():
		"Pickup":
			Log.entry(str("Picked up ", rng.randi_range(0, items.size()), " x", rng.randi_range(1, 6), "."))
		"Combine": 
			Log.entry(str("Combined ItemA[Gunpowder] and itemB[Uncased Bullets] to create item[Handgun Ammo] x3."))
		"Discard": 
			Log.entry(str("Discarded [", items[randi_range(0, items.size())], "] x", randi_range(1, 6), "."))
		"Death": 
			Log.entry("Player died")
		"Respawn": 
			Log.entry(str("Player respawned @", Vector2(randi_range(0, 512), randi_range(0, 512)), "."))
		"Load":
			Log.entry(str("Loaded GameSave#1 on Slot#", randi_range(1, 3), "."))
		"Save": 
			Log.entry(str("Saved GameSave#1 on Slot#", randi_range(1, 3), "."))
		"Exit": 
			Log.entry("Exited game, closing session.")
		
	var _file = FileAccess.open(FILE, FileAccess.READ)
	var _content = _file.get_as_text()
	label.text = _content
