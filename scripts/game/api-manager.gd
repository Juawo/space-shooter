extends Node

signal nickname_updated(status_code)
signal submited_score(status_code)
signal got_leaderboard(status_code, items)
signal got_player_rank(status_code, rank, score)

var leaderboardKey = "outerspaceleaderboard"

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS

## Player functions
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

## Score/Leaderboard functions

func submit_score(new_score: int) -> void:
	var response = await LL_Leaderboards.SubmitScore.new(leaderboardKey, new_score, SaveManager.playerIdentifier).send()
	submited_score.emit(response.status_code)
	if SaveManager.memberId == "" or SaveManager.memberId == null :
		SaveManager.update_memberId(response.member_id)

func get_leaderboard(count: int) -> void:
	var response = await LL_Leaderboards.GetScoreList.new(leaderboardKey, count).send()
	got_leaderboard.emit(response.status_code, response.items)

func get_player_rank() -> void:
	var response = await LL_Leaderboards.GetMemberRank.new(leaderboardKey, SaveManager.memberId).send()
	got_player_rank.emit(response.status_code, response.rank, response.score)
