class_name DialogueInteractionArea
extends Area2D

const DIALOGUE_FILE_PATH :String = "res://systems/dialogue/dialogue.json"

## The conversation title, used to determine which set of dialogue_items to display from dialogue.json
@export var conversation_title :String = "knight_and_percival_introduction"
## The UI that displays conversations
@onready var dialogue_display_system : DialogueDisplaySystem = $CanvasLayer/DialogueDisplaySystem

var dialogue_items :Array[DialogueItem] = [] ## Holds all the DialogueItems for a given conversation_title
var _interaction_enabled := true ## Dialogue conversations occur 1x.  Disabled on first player interaction until queue_free()


func _ready() -> void :
	self.process_mode = Node.PROCESS_MODE_ALWAYS # Pause the game during conversations. Don't pause this script.
	_load() # load the current conversation into the dialogue_items array
	dialogue_display_system.option_chosen.connect(_on_option_chosen)
# ***************************************************************************************************************** INFO ALERT
	# I imagine this system would break if I grab focus on an option in the dialogue_display_system inspector, 
	# as I am only hiding all the dialogue guis not disabling any active option buttons. so if something breaks,
	# maybe instanciate a new dialogue display system when the player interacts instead of having it in the scene to begin with
	dialogue_display_system.hide()


## Activate the dialogue UI if the player is in the area and interacts with it.
func _input(event: InputEvent) -> void:
	var is_interaction_request = ( # true if player has pressed "interact" while in the interaction area
		(event is InputEventKey or event is InputEventJoypadButton) and 
		event.is_pressed() and
		event.is_action("interact") and 
		self.has_overlapping_areas() and
		_interaction_enabled # conversations occur 1 time
	)
	if is_interaction_request:
		# pause the game, start the conversation at [0], and show the gui
		_interaction_enabled = false # disable possibility to start converstaoin
		dialogue_display_system.show()
		dialogue_display_system.display_message(dialogue_items[0])
		get_tree().paused = true
		

## Continue the conversation or unpause the game if the -1 (end conversation) option is chosen.
func _on_option_chosen(goto_message_index_result:int) -> void :
	if goto_message_index_result == -1:
		get_tree().paused = false
		self.queue_free()
		return
	dialogue_display_system.display_message(dialogue_items[goto_message_index_result-1])


## Loads the dialogue_items array for the current conversation
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

		
