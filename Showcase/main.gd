extends Control

## Disregard this script. Only exists to facilitate the showcase simulations in the example scene.

@onready var session_status_lbl: RichTextLabel = %SessionStatusLbl
@onready var gamelog: Label = $LogContents/MarginContainer/ScrollContainer/VBoxContainer/HBoxContainer2/GAMElog
@onready var uilog: Label = $LogContents/MarginContainer/ScrollContainer/VBoxContainer/HBoxContainer2/UIlog
@onready var playerlog: Label = $LogContents/MarginContainer/ScrollContainer/VBoxContainer/HBoxContainer2/PLAYERlog
const INDICATOR_1 = preload("res://Showcase/Indicator1.png")
const INDICATOR_2 = preload("res://Showcase/Indicator2.png")
@onready var npr1: NinePatchRect = $VBoxContainer/LogActions/MarginContainer/VBoxContainer/HBoxContainer/NinePatchRect
@onready var npr2: NinePatchRect = $VBoxContainer/LogActions/MarginContainer/VBoxContainer/HBoxContainer/NinePatchRect2
@onready var npr3: NinePatchRect = $VBoxContainer/LogActions/MarginContainer/VBoxContainer/HBoxContainer/NinePatchRect3

var rng := RandomNumberGenerator.new()
const F_GAME = "user://logs/game.log"
const F_UI = "user://logs/ui.log"
const F_PLAYER = "user://logs/player.log"


func _ready() -> void:
	randomize()
	GoLogger.session_status_changed.connect(_on_session_status_changed)
	for c in $VBoxContainer/LogActions/MarginContainer/VBoxContainer/GridContainer.get_children(): # Log action buttons
		if c is Button:
			c.button_up.connect(_on_session_button_up.bind(c))
	for c in $VBoxContainer/Simulations/MarginContainer/VBoxContainer.get_children(): # Event Simulation buttons
		if c is Button:
			c.button_up.connect(_on_button_up.bind(c))
	
	var _fg = FileAccess.open(F_GAME, FileAccess.READ)
	var _gc = _fg.get_as_text()
	gamelog.text = _gc
	var _fui = FileAccess.open(F_UI, FileAccess.READ)
	var _uic = _fg.get_as_text()
	uilog.text = _uic
	var _pg = FileAccess.open(F_PLAYER, FileAccess.READ)
	var _pc = _fg.get_as_text()
	playerlog.text = _gc


## Receives signal from [GoLogger] whenever a status is changed.
func _on_session_status_changed():
	print("emitted")
	if GoLogger.game_session_status: npr1.texture = INDICATOR_1
	else: npr1.texture = INDICATOR_2
	if GoLogger.ui_session_status: npr2.texture = INDICATOR_1
	else: npr2.texture = INDICATOR_2
	if GoLogger.player_session_status: npr3.texture = INDICATOR_1
	else: npr3.texture = INDICATOR_2

## Buttons that starts/stops sessions.
func _on_session_button_up(btn : Button):
	match btn.get_name():
		"StartGAME": Log.start_session(0)
		"StartUI": Log.start_session(1)
		"StartPLAYER": Log.start_session(2)
		"StopGAME": Log.stop_session(0)
		"StopUI": Log.stop_session(1)
		"StopPLAYER": Log.stop_session(2)
	var _fg = FileAccess.open(F_GAME, FileAccess.READ)
	var _cg = _fg.get_as_text()
	gamelog.text = _cg
	var _fui = FileAccess.open(F_UI, FileAccess.READ)
	var _cui = _fui.get_as_text()
	uilog.text = _cui
	var _fp = FileAccess.open(F_PLAYER, FileAccess.READ)
	var _cp = _fp.get_as_text()
	playerlog.text = _cp

## Buttons that simulates log entries.
func _on_button_up(btn : Button):
	var items : Array[String] = [
		"Pipe",
		"Handgun",
		"Gunpowder",
		"Uncased Bullets"
	]
	match btn.get_name():
		"Pickup":
			Log.entry(1, str("Picked up ", items[rng.randi_range(0, items.size() -1)], " x", rng.randi_range(1, 6), "."))
		"Combine": 
			Log.entry(1, str("Combined ItemA[Gunpowder] and itemB[Uncased Bullets] to create item[Handgun Ammo] x", rng.randi_range(1, 6), "."))
		"Discard": 
			Log.entry(1, str("Discarded [", items[rng.randi_range(0, items.size() -1)], "] x", randi_range(1, 6), "."))
		"Death": 
			Log.entry(2, "Player died")
		"Respawn": 
			Log.entry(2, str("Player respawned @", Vector2(randi_range(0, 512), randi_range(0, 512)), "."))
		"Load":
			Log.entry(0, str("Loaded GameSave#1 on Slot#", randi_range(1, 3), "."))
		"Save": 
			Log.entry(0, str("Saved GameSave#1 on Slot#", randi_range(1, 3), "."))
		"Exit": 
			Log.entry(0, "Exited game, closing session.")
		
	var _fg = FileAccess.open(F_GAME, FileAccess.READ)
	var _cg = _fg.get_as_text()
	gamelog.text = _cg
	var _fui = FileAccess.open(F_UI, FileAccess.READ)
	var _cui = _fui.get_as_text()
	uilog.text = _cui
	var _fp = FileAccess.open(F_PLAYER, FileAccess.READ)
	var _cp = _fp.get_as_text()
	playerlog.text = _cp
