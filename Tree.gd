extends StaticBody2D

var dialog = 'res://Storyfiles/MBTBaked.tres'
var dialog_name = 'MBT'


func _on_MBT_Dialog_body_entered(body: Node) -> void:
	body.dialog = dialog
	body.dialog_name = dialog_name

func _on_MBT_Dialog_body_exited(body: Node) -> void:
	body.dialog = null
	body.dialog_name = null
