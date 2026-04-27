class_name DBCategoryModule extends FoldableContainer

@onready var entry_container: VBoxContainer = %EntryContainer

var category_name: String:
	set(value):
		category_name = value
		title = value
var entries: Array = [] # 2D array of Label reference + associated entry
var entry_limit: int = 0


func _ready():
	for c in entry_container.get_children():
		c.queue_free()



func add_msg(msg: String) -> void:
	var lbl := Label.new()
	entry_container.add_child(lbl)

	var lset = LabelSettings.new()
	lset.font_size = 10
	lset.outline_color = Color.BLACK
	lset.outline_size = 4
	lbl.label_settings = lset

	lbl.text = msg
	var e: Array = [lbl, msg]
	entries.append(e)
	while entries.size() >= entry_limit -1:
		remove_msg()



func remove_msg() -> void:
	# for child in entry_container.get_children():
	# 	if child == entries[0][0]:
	entries[0][0].queue_free()
	entries.remove_at(0)