extends Node2D

# Variables for dialog

var options

# States

var is_waiting # if the text_display animation finishes displaying, this will become true and allow the continuation of dialogue

var has_choices # if there are dialog options available, this will be True and disable the Spacebar function.

# Node Tree References

onready var _Body_LBL = find_node("Body_Label")
onready var _Dialog_Box = find_node("Dialog_Box")
onready var _Speaker_LBL = find_node("Speaker_Label")
onready var _Registry = find_node("Simulated_Registry")
onready var _Option_List = find_node('Option_List')
onready var _Option_Button_Scene = load("res://Templates & Misc/Option.tscn")
onready var _Body_AnimationPlayer = self.find_node("Body_AnimationPlayer")

onready var player = find_node("../../YSort/Player YSORT/Player")

# file system stuff

# Global Variables

var _did = 0
var _nid = 0
var _final_nid = 0
var _Story_Reader 

# Virtual Methods

func start_dialog(storyfile, story_name):
	is_waiting = false
	
	var Story_Reader_Class = load("res://addons/EXP-System-Dialog/Reference_StoryReader/EXP_StoryReader.gd")
	_Story_Reader = Story_Reader_Class.new()
		
	var story = load(storyfile)
	_Story_Reader.read(story)
	_Dialog_Box.visible = false
	
	_clear_options()

	play_dialog(story_name)
		
func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("ui_interact"):
		if is_waiting and not has_choices:
			_on_Dialog_Player_pressed_spacebar()

# Callback Methods

func _on_Option_clicked(slot):
	_Option_List.visible = false
	_get_next_node(slot)
	_clear_options()
	if _is_playing():
		_play_node()

func _on_Dialog_Player_pressed_spacebar():
	print('ayo the pizza here')
	_get_next_node()
	if _is_playing():
		_play_node()

# Public Methods

func play_dialog(record_name : String):
	_did = _Story_Reader.get_did_via_record_name(record_name)
	_nid = _Story_Reader.get_nid_via_exact_text(_did, "<start>")
	_final_nid = _Story_Reader.get_nid_via_exact_text(_did, "<end>")
	_get_next_node()
	_play_node()
	_Dialog_Box.visible = true

# Private Methods

func _clear_options():
	var children = _Option_List.get_children()
	for child in children:
		_Option_List.remove_child(child)
		child.queue_free()
		
func _is_playing() -> bool:
	return _Dialog_Box.visible
	
func _get_next_node(slot : int = 0):
	_nid = _Story_Reader.get_nid_from_slot(_did, _nid, slot)
	
	if _nid == _final_nid:	
		
		_Dialog_Box.visible = false

		queue_free()
	
		get_tree().paused = false
		
func _get_tagged_text(tag : String, text : String) -> String:
	var start_tag = "<" + tag + ">"
	var end_tag = "</" + tag + ">"
	var start_index = text.find(start_tag) + start_tag.length()
	var end_index = text.find(end_tag)
	var substr_length = end_index - start_index
	
	return text.substr(start_index, substr_length)

func _inject_variables(text: String) -> String:
	var variable_count = text.count("<variable>")

	for i in range(variable_count):
		var variable_name = _get_tagged_text('variable', text)
		var variable_value = _Registry.lookup(variable_name)
		var start_index = text.find('<variable>')
		var end_index = text.find('</variable>') + "</variable>".length()
		var substr_length = end_index - start_index
		text.erase(start_index, substr_length)
		text = text.insert(start_index, str(variable_value))
	
	return text
	
func _play_node():
	var text = _Story_Reader.get_text(_did, _nid)
	text = _inject_variables(text)
	var speaker = _get_tagged_text("speaker", text)
	var dialog = _get_tagged_text("dialog", text)
	if "<choiceJSON>" in text:
		has_choices = true
		options = _get_tagged_text("choiceJSON", text)
	else:
		has_choices = false
	
	_Speaker_LBL.text = speaker
	_Body_LBL.text = dialog
	is_waiting = false
	_Body_AnimationPlayer.play("TextDisplay")

func _populate_choices(JSONtext : String):
	var choices: Dictionary = parse_json(JSONtext)
	
	for text in choices: 
		var slot = choices[text]
		var new_option_button = _Option_Button_Scene.instance()
		_Option_List.add_child(new_option_button)
		new_option_button.slot = slot
		new_option_button.set_text(text)
		new_option_button.connect('clicked', self, '_on_Option_clicked')
		is_waiting = true

func _on_Body_AnimationPlayer_animation_finished(anim_name):
	_populate_choices(options)
	is_waiting = true
