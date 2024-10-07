extends Node

var dialogue_items :Array[DialogueItem] = []
#@export_file("*.json") 
var DIALOGUE_FILE_PATH :String = "res://dialogue.csv"

func _ready() -> void :
	_load_dialogue_items()
	for item in dialogue_items:
		print(item.message)
		print(item.choices)



func _load_dialogue_items() -> void :
	if DIALOGUE_FILE_PATH == null:
		push_error("The dialogue file for ", owner.name, " is not specified.")
		return
	var file = FileAccess.open(DIALOGUE_FILE_PATH, FileAccess.READ)
	while not file.eof_reached():
		var line_array = file.get_csv_line(";")
		var dialogue_item = DialogueItem.new()
		dialogue_item.message = line_array[0]
		for index in range(1, line_array.size()):
			dialogue_item.choices.append(line_array.duplicate()[index])
		dialogue_items.append(dialogue_item)
	file.close()



class DialogueItem:
	var message : String = ""
	var choices : Array[String] = []
