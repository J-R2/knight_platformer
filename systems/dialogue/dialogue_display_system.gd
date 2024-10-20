class_name DialogueDisplaySystem
extends Control

@onready var message_label: RichTextLabel = %MessageLabel
@onready var options_container: VBoxContainer = %OptionsContainer
@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer


signal option_chosen(goto_message_index_result:int)

func _ready() -> void:
	pass


func display_messsage(dialogue_item :DialogueItem) -> void:
	for child in options_container.get_children():
		if child is Button: child.queue_free()
	message_label.text = dialogue_item.message
	message_label.visible_ratio = 0.0
	var message_tween = create_tween()
	var duration = message_label.text.length() / 25.0
	message_tween.tween_property(message_label, "visible_ratio", 1.0, duration)	
	await message_tween.finished
	for option in dialogue_item.options:
		create_button(option)
	await option_chosen


func create_button(option :Dictionary) -> void:
	var button = Button.new()
	button.text = option[DialogueItem.OPTION_TEXT]
	if button.text.length() > 40:
		for i in range(floori(button.text.length() / 40)):
			for ii in range(40*(i+1), 0, -1):
				print(button.text[ii])
				if button.text[ii] == " ":
					button.text = button.text.insert(ii, "\n")
					break
	#button.pressed.connect(audio_stream_player.play)
	#button.focus_entered.connect(audio_stream_player.play)
	#button.mouse_entered.connect(audio_stream_player.play)
	button.pressed.connect(func() -> void :
		option_chosen.emit(option[DialogueItem.GOTO_MESSAGE_INDEX])
	)
	options_container.add_child(button)
	
