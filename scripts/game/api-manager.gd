extends Node

signal nickname_updated(response_code)

var register_scene := preload("res://scenes/ui/Register/register.tscn")

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS

func register_session_player(playerIdentifier: String) -> bool :
	var guestLoginResponse = await LL_Authentication.GuestSession.new(playerIdentifier).send()
	if(!guestLoginResponse.success) :
		printerr("Guest login failed with reason: " + guestLoginResponse.error_data.to_string())
		return false
	if playerIdentifier == null or playerIdentifier.is_empty() :
		SaveManager.update_player_identifier(guestLoginResponse.player_identifier)
	print("Guest user was successfully signed in to LootLocker")
	return true

func update_nickname(new_nickname : String) -> void:
	var response = await LL_Players.SetPlayerName.new(new_nickname).send()
	if(response.success) :
		SaveManager.update_nickname(response.name)
	nickname_updated.emit(response.status_code)
