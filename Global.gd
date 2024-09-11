extends Node

signal session_toggle(status : bool) 
var log_session = false
var log_on_dev = true

func _ready() -> void:
	GameLog.start_session()
