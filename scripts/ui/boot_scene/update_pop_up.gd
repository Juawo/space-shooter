extends Control


var uri : String

@onready var title: Label = $MarginContainer/Panel/MarginContainer/VBoxContainer/title
@onready var content: Label = $MarginContainer/Panel/MarginContainer/VBoxContainer/content
@onready var no_update_btn: Button = $MarginContainer/Panel/MarginContainer/VBoxContainer/no_update_btn
@onready var update_btn: Button = $MarginContainer/Panel/MarginContainer/VBoxContainer/update_btn
@onready var erro_update_btn: Label = $MarginContainer/Panel/MarginContainer/VBoxContainer/erro_update_btn

func populate_pop_up(new_version_data : Dictionary, old_version_data : String) -> void :
	if new_version_data.has("isMandatory"):
		no_update_btn.disabled = new_version_data["isMandatory"]
		no_update_btn.visible = new_version_data["isMandatory"]
	
	if new_version_data.has("currentVersion"):
		content.text = "You game is using the version %s, and the most recente version is %s \n
		Follow the instructions file in the page!" %[old_version_data, new_version_data["currentVersion"]]
	
	if new_version_data.has("downloadUrl"):
		update_btn.disabled = false
		erro_update_btn.visible = false
		uri = new_version_data["downloadUrl"]
	else :
		update_btn.disabled = true
		erro_update_btn.visible = true

func _on_update_btn_pressed() -> void:
	OS.shell_open(uri)

func _on_no_update_btn_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/game/main.tscn")
