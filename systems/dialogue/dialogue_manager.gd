extends Node

@export var conversation_title :String = "knight_and_percival_introduction"
#@export_file("*.json") var
const DIALOGUE_FILE_PATH :String = "res://systems/dialogue/dialogue.json"

var dialogue_items :Array[DialogueItem] = []



func _ready() -> void :
	#if conversation_title == "":
		#printerr("conversation_title for ", owner.name, " was not specified. Please do so in their DialogueManager Node Inspector panel.")
	_load()
	for item in dialogue_items:
		print(item.message_index, ".  ", item.message)
		for option in item.options:
			print(option[item.OPTION_TEXT], " -> ", option[item.GOTO_MESSAGE_INDEX])



## loads the dialogue_items array for the current conversation
func _load() -> void :
	var file = FileAccess.open(DIALOGUE_FILE_PATH, FileAccess.READ)
	var json_line :String = ""
	while not file.eof_reached(): # the JSON is seperated by /n and /t, must combine lines and remove tabs
		var line = file.get_line()
		json_line += line.strip_edges()
	file.close()
	
	var loaded_array_of_conversations :Array[Dictionary] = [] # holds the array of all conversations and their dialogue_items arrays
	var temp_array_of_jsonified_conversations = json_line.split("}]}]}") # separate the dialogue conversations
	for line in temp_array_of_jsonified_conversations:
		line += "}]}]}" # add the separated text to the end of the string
		if line == "}]}]}": # ignore the final separation
			continue
		var parsed_json_dict = JSON.parse_string(line) # retrieve the data from the json string
		loaded_array_of_conversations.append(parsed_json_dict) # finally in a proper variable, an array of dictionaries, containing dictionaries with arrays of dictionaries
	
	for conversation in loaded_array_of_conversations: # go through all the conversations in the array
		if conversation["conversation_title"] == conversation_title: # find this conversation's dictionary
			var save_conversation_dialogue = conversation_title.to_lower() + "_" + "dialogue_items"
			for item in conversation[save_conversation_dialogue]: # go through this conversation's saved dialogue_items and set the data
				var dialogue_item = DialogueItem.new()
				dialogue_item.message_index = item["message_index"]
				dialogue_item.message = item["message"]
				for option in item["options"]:
					dialogue_item.options.append(option)
				dialogue_items.append(dialogue_item)




## saves the dialogue in the proper format, no longer needed
func _save() -> void :
	var file = FileAccess.open(DIALOGUE_FILE_PATH, FileAccess.WRITE)
	var save_conversation_dialogue = conversation_title.to_lower() + "_" + "dialogue_items"
	var save_dict = {
		"conversation_title" : conversation_title.to_lower(),
		save_conversation_dialogue : []
	}
	for item in dialogue_items:
		var new_dict = {
			"message_index" : item.message_index,
			"message" : item.message,
			"options" : item.options,
		}
		save_dict[save_conversation_dialogue].append(new_dict)
	file.store_line(JSON.stringify(save_dict, "\t"))
	file.close()

## A dialogue item, contains a main message with index, and options displayed for character input.
## each option has a goto message index which will display the next message in the dialogue conversation until quit (-1)
class DialogueItem:
	const OPTION_TEXT = "option_text"
	const GOTO_MESSAGE_INDEX = "goto_message_index"
	var message_index :int = 0
	var message :String = ""
	var options :Array[Dictionary] = []
	
	func add_dialogue_option(new_option_text:String, new_goto_message_index:int = -1):
		if new_goto_message_index > 0: new_goto_message_index -= 1
		var dialogue_option = {
			OPTION_TEXT : new_option_text,
			GOTO_MESSAGE_INDEX : new_goto_message_index,
		}
		options.append(dialogue_option)

		
