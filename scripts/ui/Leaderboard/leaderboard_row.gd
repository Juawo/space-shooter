extends Control

@export var rank_pos : String
@export var nickname : String
@export var high_score : int
@export var base_color : Color

@onready var rank_label: Label = $MarginContainer/HBoxContainer/rank_label
@onready var nickname_label: Label = $MarginContainer/HBoxContainer/nickname_label
@onready var high_score_label: Label = $MarginContainer/HBoxContainer/high_score_label

func populate(data : Dictionary, rank : int) :
	rank_label.text = rank_text(rank)
	#rank_label.theme_override_colors.font_color = base_color
	
	nickname_label.text = str(data.playerNickname)
	#nickname_label.theme_override_colors.font_color = base_color

	high_score_label.text = str(int(data.highScoreValue))
	#high_score_label.theme_override_colors.font_color = base_color

func rank_text(rank : int) -> String:
	match rank:
		1 : 
			return str(rank) + "st"
		2 : 
			return str(rank) + "nd"
		3 : 
			return str(rank) + "rd"
		_: 
			return str(rank) + "th"
