extends Node

# MUSIC
var GAME_MUSIC_BASE = preload("uid://dv3ifl48m2n86")
var INTERFACE_MUSIC_BASE = preload("uid://1rw715gqevmi")
var NEW_HIGH_SCORE = preload("uid://djaaaroa0ebjp")

# SFX
## UI
const CLICK_002 = preload("uid://cgivah1ow0lfe")
const CLICK_003 = preload("uid://befaktrx3s5ef")

const SCROLL_UP = preload("uid://b4ogl4puigivt")
const SCROLL_DOWN = preload("uid://bjfadght34wsd")

## GAME
const IMPACT_PLATE_HEAVY_001 = preload("uid://mqcl8xqg0gmr")
const IMPACT_PLATE_HEAVY_002 = preload("uid://djh4d1c0duqwd")
const IMPACT_PLASMA = preload("uid://brd6o0wpb22g")

const DISPARE_1 = preload("uid://n0pifq8gemk8")
const DISPARE_2 = preload("uid://24c3los45y4c")
const DISPARE_3 = preload("uid://bipnd4eks3500")
const DISPARE_PLASMA = preload("uid://cdhukq3yj11yb")

const EXPLOSION_1 = preload("uid://dfvbd5tjubhch")
const EXPLOSION_2 = preload("uid://c1j0dic36ft6f")
const EXPLOSION_3 = preload("uid://c0k13ktpdlwy6")

const LIFE_ALARM = preload("uid://vhusj7fpq3um")

const PICK_UP_POWERUP = preload("uid://u0pshwcjwhsc")
const PICK_UP_SHIELD = preload("uid://bggaccr38nx0v")

const POWER_UP_FINISHING = preload("uid://cec0lyqosui3l")

var music_player : AudioStreamPlayer
var music_bus_idx : int
var lowpass_effect_idx := 0

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	music_bus_idx = AudioServer.get_bus_index("Music")
	_setup_music_player()
	set_music_opaque(true)
	update_music_volume(SaveManager.music_volume)
	update_sfx_volume(SaveManager.sfx_volume)
	
func _setup_music_player() -> void :
	music_player = AudioStreamPlayer.new()
	music_player.bus = "Music"
	add_child(music_player)
	
	INTERFACE_MUSIC_BASE.loop = true
	GAME_MUSIC_BASE.loop = true
	
	music_player.stream = INTERFACE_MUSIC_BASE
	play_music()

func _switch_music_to(music : AudioStream) -> void :
	if music_player.stream == music :
		return
	
	set_music_opaque(true)
	
	var tween = create_tween().set_trans(Tween.TRANS_LINEAR)
	tween.tween_property(music_player, "volume_db", -50.0, 0.6)
	await tween.finished
	
	music_player.stop()
	
	music.loop = true
	
	music_player.stream = music
	music_player.volume_db = 0.0
	music_player.play()
	
	await get_tree().create_timer(1).timeout
	
	set_music_opaque(false)

func switch_music_to_game() -> void :
	_switch_music_to(GAME_MUSIC_BASE)

func switch_music_to_interface() -> void :
	_switch_music_to(INTERFACE_MUSIC_BASE)
	
func play_music() -> void :
	if not music_player.playing :
		music_player.play()

func stop_music() -> void :
	if music_player.playing :
		music_player.stop()

func set_music_opaque(is_opaque : bool) -> void :
	if music_bus_idx != -1 :
		AudioServer.set_bus_effect_enabled(music_bus_idx, lowpass_effect_idx, is_opaque)

# EXTERNAL FUNCTIONS

func _play_sfx(stream : AudioStream) -> void :
	if stream == null :
		return
	
	var sfx_player = AudioStreamPlayer.new()
	sfx_player.stream = stream
	sfx_player.bus = "SFX"
	add_child(sfx_player)
	sfx_player.play()
	
	sfx_player.finished.connect(func(): sfx_player.queue_free())

func update_sfx_volume(volume : float) -> void :
	var bus_index  = AudioServer.get_bus_index("SFX")
	if bus_index != -1 :
		var local_linear = volume / 100.0
		var db = linear_to_db(local_linear)
		AudioServer.set_bus_volume_db(bus_index, db)
		AudioServer.set_bus_mute(bus_index, volume == 0.0)

func update_music_volume(volume : float) -> void :
	var bus_index  = AudioServer.get_bus_index("Music")
	if bus_index != -1 :
		var local_linear = volume / 100.0
		var db = linear_to_db(local_linear)
		AudioServer.set_bus_volume_db(bus_index, db)
		AudioServer.set_bus_mute(bus_index, volume == 0.0)

func play_click() -> void :
	var rng = RandomNumberGenerator.new()
	var num = rng.randf_range(1,2)
	if num == 1 :
		_play_sfx(CLICK_002)
	else :
		_play_sfx(CLICK_003)

func play_scroll(to_up : bool) -> void :
	if to_up :
		_play_sfx(SCROLL_UP)
	else :
		_play_sfx(SCROLL_DOWN)

func play_impact() -> void :
	var rng = RandomNumberGenerator.new()
	var num = rng.randf_range(1,2)
	if num == 1 :
		_play_sfx(IMPACT_PLATE_HEAVY_001)
	else :
		_play_sfx(IMPACT_PLATE_HEAVY_002)

func play_dispare() -> void :
	var rng = RandomNumberGenerator.new()
	var num = rng.randf_range(1,3)
	if num == 1 :
		_play_sfx(DISPARE_1)
	elif num == 2 :
		_play_sfx(DISPARE_2)
	else :
		_play_sfx(DISPARE_3)

func play_dispare_plasma() -> void :
	_play_sfx(DISPARE_PLASMA)

func play_impact_plasma() -> void :
	_play_sfx(IMPACT_PLASMA)

func play_explosion() -> void :
	var rng = RandomNumberGenerator.new()
	var num = rng.randf_range(1,3)
	if num == 1 :
		_play_sfx(EXPLOSION_1)
	elif num == 2 :
		_play_sfx(EXPLOSION_2)
	else :
		_play_sfx(EXPLOSION_3)

func play_life_alarm() -> void :
	_play_sfx(LIFE_ALARM)

func play_powerup_finishing() -> void :
	_play_sfx(POWER_UP_FINISHING)

func play_pickup_cadence() -> void:
	_play_sfx(PICK_UP_POWERUP)

func play_pickup_shield() -> void:
	_play_sfx(PICK_UP_SHIELD)
# TODO : TOCA DUAS VEZES ?
func play_new_highscore() -> void :
	stop_music()
	_play_sfx(NEW_HIGH_SCORE)
	await get_tree().create_timer(4).timeout
	play_music()
