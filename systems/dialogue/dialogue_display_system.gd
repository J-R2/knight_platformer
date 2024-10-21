## The main UI for dialogue conversations.  Displays DialogueItem(s) for a dialogue_interaction_area.
class_name DialogueDisplaySystem
extends Control

## How fast the text label should show the message.
const LETTERS_PER_SECOND :float = 30.0

@onready var message_label: RichTextLabel = %MessageLabel
@onready var options_container: VBoxContainer = %OptionsContainer ## Holds the DialogueItem options buttons
@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer #TODO Possibly add sound for player choices or voice lines.

## Emits the player selected option button's goto_message_index to request the next message.
signal option_chosen(goto_message_index_result:int) 


func display_message(dialogue_item :DialogueItem) -> void:
	for child in options_container.get_children(): # Remove all previous button choices.
		if child is Button: child.queue_free()
	message_label.text = dialogue_item.message # Set the dialogue message.
	message_label.visible_ratio = 0.0 # Hide the message.
	var message_tween = create_tween() # Tween the message visibility to display letter by letter.
	var duration = message_label.text.length() / LETTERS_PER_SECOND
	message_tween.tween_property(message_label, "visible_ratio", 1.0, duration)	
	await message_tween.finished # Display option buttons after the message is fully displayed.
	for option in dialogue_item.options:
		create_button(option)
	_set_button_focus() 
	await option_chosen # do nothing until user makes selection


## Grabs focus of the first button in the options container for easier selection.
func _set_button_focus() -> void :
	var buttons = options_container.get_children()
	if buttons:
		buttons[0].grab_focus()


## Takes a DialogueItem option Dictionary to create a button and connect it's pressed signal to emit the proper option_chosen.
func create_button(option :Dictionary) -> void:
	var button = Button.new()
	button.text = option[DialogueItem.OPTION_TEXT]
	if button.text.length() > 40: # Some options are long. Break them up into multilines to enlarge the buttons and show all text.
		for i in range(floori(button.text.length() / 40)):
			for ii in range(40*(i+1), 0, -1):
				print(button.text[ii])
				if button.text[ii] == " ":
					button.text = button.text.insert(ii, "\n")
					break
	#NOTICE I didn't like the sound. Find a better dialogue selection sound and maybe voice lines for text display.
	#button.pressed.connect(audio_stream_player.play)
	#button.focus_entered.connect(audio_stream_player.play)
	#button.mouse_entered.connect(audio_stream_player.play)
	button.pressed.connect(func() -> void :
		option_chosen.emit(option[DialogueItem.GOTO_MESSAGE_INDEX])
	)
	options_container.add_child(button)
	
