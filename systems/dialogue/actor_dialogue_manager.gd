extends Node

@export var actor_name :String = "percival"
#@export_file("*.json") var
const DIALOGUE_FILE_PATH :String = "res://systems/dialogue/dialogue.json"

var dialogue_items :Array[DialogueItem] = []



func _ready() -> void :
	#if actor_name == "":
		#printerr("actor_name for ", owner.name, " was not specified. Please do so in their ActorDialogueManager Node Inspector panel.")
	_load()



## loads the dialogue_items array for the current actor
func _load() -> void :
	var file = FileAccess.open(DIALOGUE_FILE_PATH, FileAccess.READ)
	var json_line :String = ""
	while not file.eof_reached(): # the JSON is seperated by /n and /t, must combine lines and remove tabs
		var line = file.get_line()
		json_line += line.strip_edges()
	file.close()
	
	var loaded_array_of_actors :Array[Dictionary] = [] # holds the array of all actors and their dialogue_items arrays
	var temp_array_of_jsonified_actors = json_line.split("}]}]}") # separate the dialogue actors
	for line in temp_array_of_jsonified_actors:
		line += "}]}]}" # add the separated text to the end of the string
		if line == "}]}]}": # ignore the final separation
			continue
		var parsed_json_dict = JSON.parse_string(line) # retrieve the data from the json string
		loaded_array_of_actors.append(parsed_json_dict) # finally in a proper variable, an array of dictionaries, containing dictionaries with arrays of dictionaries
	
	for actor in loaded_array_of_actors: # go through all the actors in the array
		if actor["actor_name"] == actor_name: # find this actor's dictionary
			var save_actor_dialogue = actor_name.to_lower() + "_" + "dialogue_items"
			for item in actor[save_actor_dialogue]: # go through this actor's saved dialogue_items and set the data
				var dialogue_item = DialogueItem.new()
				dialogue_item.message_index = item["message_index"]
				dialogue_item.message = item["message"]
				for option in item["options"]:
					dialogue_item.options.append(option)
				dialogue_items.append(dialogue_item)




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

		
