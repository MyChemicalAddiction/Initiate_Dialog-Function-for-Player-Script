extends KinematicBody2D

# important variables

var velocity = Vector2.ZERO
var input_vector = Vector2.ZERO

# file system stuff

const Dialog_Player = preload("res://Templates & Misc/Dialog_Player.tscn")

# node tree stuff

onready var SceneManager = find_parent('SceneManager')

# export variables

export var maxspeed = 250
export var friction = 65

export var stand_up_speed = Vector2(0, 100)

# states & misc

var state = MOVE

var dialog # the dialog that the player is currently able to engage in

var dialog_name

# node tree

onready var collisionShape = find_node("CollisionShape2D")

# functions

enum {
	MOVE,
}

func _physics_process(delta):
	match state:
		MOVE:
			move_state(delta)

func move_state(delta):
	
	input_vector = Vector2.ZERO
	input_vector.x = Input.get_action_strength('ui_right') - Input.get_action_strength("ui_left")
	input_vector.y = Input.get_action_strength('ui_down') - Input.get_action_strength("ui_up")
		
	if input_vector != Vector2.ZERO:
		velocity = input_vector * maxspeed
		velocity = velocity.clamped(maxspeed)
	else:
		velocity = velocity.move_toward(Vector2.ZERO, friction)
	
	move_and_slide(velocity)

func initiate_dialog(dialog, dialog_name):
	 
	velocity = Vector2.ZERO

	var dialog_player = Dialog_Player.instance()
		
	var world = get_tree().current_scene
	
	world.add_child(dialog_player) 
		
	dialog_player.global_position = global_position  

	dialog_player.start_dialog(dialog, dialog_name)

	get_tree().paused = true

func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("ui_interact"):
		if dialog != null and dialog_name != null: # if there is a dialog available
			initiate_dialog(dialog, dialog_name)
