## A dialogue item, contains a main message with index, and options displayed for character input.
## each option has a goto message index which will display the next message in the dialogue conversation until quit (-1)
class_name DialogueItem
extends Object

const OPTION_TEXT = "option_text"
const GOTO_MESSAGE_INDEX = "goto_message_index"

var message_index :int = 0
var message :String = ""
var options :Array[Dictionary] = []


## Deprecated, once used to save the dialogue.json in the proper format quickly
func add_dialogue_option(new_option_text:String, new_goto_message_index:int = -1):
	if new_goto_message_index > 0: new_goto_message_index -= 1
	var dialogue_option = {
		OPTION_TEXT : new_option_text,
		GOTO_MESSAGE_INDEX : new_goto_message_index,
	}
	options.append(dialogue_option)
