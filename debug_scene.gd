extends Control

@onready var db_timer: Timer = %DebugTimer
@onready var c_container: HBoxContainer = %CategoryContainer
@export var entry_limit: int = 20:
	set(value):
		if value != entry_limit:
			entry_limit = value 
			for c in c_container.get_children():
				c.entry_limit = value

const PATH = "user://gologger_data.ini"

const SIM_EVENT_TYPES := {
	"damage_taken": "damage_taken",
	"quest_accepted": "quest_accepted",
	"level_transition": "level_transition",
	"enemy_killed": "enemy_killed"
}

const SIM_ENEMIES := ["Hobgoblin", "Warg", "Grave Stalker", "Bog Witch", "Ravenous Slime"]
const SIM_QUESTS := ["Blood in the Water", "Ashes of Fenwatch", "The Lost Cartographer", "Last Ember"]
const SIM_LEVELS := ["swamp_a1.tscn", "crypt_b2.tscn", "highroad_gate.tscn", "fen_ruins_a3.tscn"]
const SIM_SKILLS := ["Heroic Slam", "Piercing Bolt", "Serrated Strike", "Ember Lance"]
const SIM_TARGET_NAMES := ["Warg", "Raider", "Hobgoblin", "Boneguard", "Fen Beast"]

const PLAYER_NAME := "Player"
const PLAYER_MAX_HP := 100

var config := ConfigFile.new()
var sim_hp: int = PLAYER_MAX_HP

var c_module = preload("uid://dgdg4n7lsq031")


func _ready() -> void:
	randomize()
	db_timer.timeout.connect(_on_timer_timeout)
	Log.msg_logged.connect(_on_msg_logged)
	config.load(PATH)

	for child in c_container.get_children():
		child.queue_free()

	for c in config.get_value("categories", "category_names", []):
		var _n = c_module.instantiate() as DBCategoryModule
		c_container.add_child(_n)
		_n.category_name = c
		_n.entry_limit = entry_limit


func _pick_from(pool: Array) -> String:
	if pool.is_empty():
		return ""

	return str(pool[randi() % pool.size()])


func _sim_damage_taken() -> String:
	var enemy := _pick_from(SIM_ENEMIES)
	var damage := randi_range(8, 36)
	sim_hp = maxi(0, sim_hp - damage)

	# Occasionally heal a bit so the stream stays varied over longer runs.
	if sim_hp == 0:
		sim_hp = randi_range(42, PLAYER_MAX_HP)

	return str(PLAYER_NAME, " took ", damage, " damage from ", enemy, ". Current HP ", sim_hp, " / ", PLAYER_MAX_HP)


func _sim_quest_accepted() -> String:
	var quest := _pick_from(SIM_QUESTS)
	return str(PLAYER_NAME, " accepted quest '", quest, "'")


func _sim_level_transition() -> String:
	var level := _pick_from(SIM_LEVELS)
	return str("Transitioned to level '", level, "'")


func _sim_enemy_killed() -> String:
	var enemy := _pick_from(SIM_TARGET_NAMES)
	var skill := _pick_from(SIM_SKILLS)
	var damage := randi_range(60, 180)
	return str("Enemy ", enemy, " killed by ", PLAYER_NAME, " [", skill, "] for ", damage, " damage.")


func _build_simulated_entry() -> String:
	var event_type := _pick_from(SIM_EVENT_TYPES.values())

	match event_type:
		"damage_taken":
			return _sim_damage_taken()
		"quest_accepted":
			return _sim_quest_accepted()
		"level_transition":
			return _sim_level_transition()
		"enemy_killed":
			return _sim_enemy_killed()
		_:
			return "Player rested at campfire."



func _on_msg_logged(category_name: String, msg: String) -> void:
	for child in c_container.get_children():
		if child.category_name == category_name:
			child.add_msg(msg)
		


func _on_timer_timeout() -> void:
	if !FileAccess.file_exists(PATH):
		return

	var _result = config.load(PATH)

	if _result != OK:
		return

	var cats: Array = config.get_value("categories", "category_names", [])
	var def_c: String = config.get_value("categories", "default_category", "")

	if cats.is_empty() or cats == null: return

	for c in cats:
		Log.msg(_build_simulated_entry(), c, true)

	if def_c != "":
		Log.msg(_build_simulated_entry(), def_c)
