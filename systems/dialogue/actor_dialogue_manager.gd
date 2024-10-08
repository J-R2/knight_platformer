extends Node

@export var actor_name :String = "percival"
#@export_file("*.json") var
const DIALOGUE_FILE_PATH :String = "res://systems/dialogue/dialogue.json"

var dialogue_items :Array[DialogueItem] = []



func _ready() -> void :
	#_load_dialogue_items()
	#var dialogue_item = DialogueItem.new()
	#dialogue_item.message = "Hey you! Come over here!"
	#dialogue_item.message_index = 1
	#dialogue_item.add_dialogue_option("Okay, what do you want?", 3)
	#dialogue_item.add_dialogue_option("No.", 2)
	#dialogue_items.append(dialogue_item)
	#for item in dialogue_items:
		#print(item.message)
		#print(item.options)
	#_save()
	pass
	
	
## saves the dialogue in the proper format, no longer needed
func _save() -> void :
	var file = FileAccess.open(DIALOGUE_FILE_PATH, FileAccess.WRITE)
	var save_actor_dialogue = actor_name.to_lower() + "_" + "dialogue_items"
	var save_dict = {
		"actor_name" : actor_name.to_lower(),
		save_actor_dialogue : []
	}
	for item in dialogue_items:
		var new_dict = {
			"message_index" : item.message_index,
			"message" : item.message,
			"options" : item.options,
		}
		save_dict[save_actor_dialogue].append(new_dict)
	file.store_line(JSON.stringify(save_dict, "\t"))
	file.close()
	


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
	const OPTION_TEXT = "option_text"
	const GOTO_MESSAGE_INDEX = "goto_message_index"
	var message :String = ""
	var message_index :int = 0
	var options :Array[Dictionary] = []
	
	func add_dialogue_option(new_option_text:String, new_goto_message_index:int = -1):
		if new_goto_message_index > 0: new_goto_message_index -= 1
		var dialogue_option = {
			OPTION_TEXT : new_option_text,
			GOTO_MESSAGE_INDEX : new_goto_message_index,
		}
		options.append(dialogue_option)

		
