extends Node

var player
var lr=50 #Light radius
var state='Stage_begin'
var t=0
var artifacts=0
#States: 
const vector_normal = Vector2(0, -1)
const vector_gravity_up = Vector2(0, 10)
const vector_gravity_down = Vector2(0, 15)

var tile_size=Vector2(16,16)

var stage_list=[
	"res://Scenes/debug.tscn",
	"res://Scenes/stages/1.tscn",
	"res://Scenes/stages/2.tscn",
	"res://Scenes/stages/3.tscn",
	"res://Scenes/stages/4.tscn"
]
var stage_index=0
var twn

var minutes=0
var seconds=0

const stage_fadein=preload("res://Scenes/twn_stagefadein.tscn")
const stage_reseter=preload("res://Scenes/stage_reseter.tscn")
const pause_manager=preload("res://Scenes/pause_manager/pause_manager.tscn")
const music1=preload("res://Scenes/music1.tscn")
const music2=preload("res://Scenes/music2.tscn")
const blue_tint=Color('ffffff')#Color('cc94d4ff')
const red_tint=Color('ffa5a5ff')
func _ready():
	randomize()
	OS.window_size*=2
	
	print('Global: Creating a Tween node...')
	var i=Tween.new()
	i.name='twn'
	add_child(i)
	twn=get_node('twn')
	print('Global: Done creating a Tween node.')
	
	print('Global: Adding the Pause Manager to childrens...')
	add_child(pause_manager.instance())
	print('Global: Done adding the Pause Manager.')
	
	print('Global: Creating a Canvas Modulate to add some blue tint to the screen...')
	var j=CanvasModulate.new()
	j.name='tint'
	j.color=blue_tint
	add_child(j)
	print('Global: Done adding the Canvas Modulate.')
	
	print('Global: Turning processing on, for displaying the FPS on the window name...')
	set_process(true)
	print('Global: Done turning processing on.')
	
	print('Global: Adding the first music...')
	var k=music1.instance()
	k.name='music'
	add_child(k)
	print('Global: Done! Have fun with the same chord played over and over!')
	
	print('Global: Creating a Timer for the people that will speedrun this game...')
	print('Global: (I guess no one will do such thing, but... meh, whatever I guess)')
	var l=Timer.new()
	l.name='timer'
	l.wait_time=60
	l.autostart=false
	l.one_shot=false
	l.connect("timeout", global, 'add_to_minutes')
	add_child(l)
	print('Global: Done! Timer added.')
	
	print('Global: Ready! Hope you have fun!')

func add_to_minutes(): minutes+=1
func startTimer(): $timer.start()
func _process(delta):
	if Input.is_action_just_pressed('ui_mute'):
		AudioServer.set_bus_mute(AudioServer.get_bus_index('Master'), !AudioServer.is_bus_mute(AudioServer.get_bus_index('Master')))
	OS.set_window_title('DIVER DOWN - FPS: ' + str(Engine.get_frames_per_second()))

func next_stage(): #@ Add a delay here maybe
	get_tree().current_scene.queue_free()
	stage_index+=1
	state='Stage_begin'
	get_tree().change_scene(stage_list[stage_index])

func change_stage(stage):
	var target=get_tree().current_scene
	twn.interpolate_property(target, 'modulate:a', target.modulate.a, 0, 0.4, Tween.TRANS_QUART, Tween.EASE_IN)
	twn.start()
	yield(twn, "tween_completed")
#	var i=stage.instance()
#	i.add_child(stage_fadein.instance())
	if stage.instance().get_node('stage/str_stagename').text=='Stage 2: Going up':
		startTimer()
	if stage.instance().get_node('stage/str_stagename').text=='Stage 4: Walls are only a suggestion':
		$music.fade()
	if stage.instance().get_node('stage/str_stagename').text=='Stage 5: Dive down':
		var k=music2.instance()
		k.name='music'
		add_child(k)
	if stage.instance().get_node('stage/str_stagename').text=='End':
		$music.fade()
		var k=music1.instance()
		k.name='music1'
		add_child(k)
		$timer.stop()
		seconds=round($timer.time_left)
	get_tree().change_scene_to(stage)
	changeFromLowPassMusic()
	
func reload_stage():
	if get_tree().current_scene.modulate.a==1:
		changeFromLowPassMusic()
		print('Global: Reseting current stage.')
		get_tree().paused=true
		$tint.color=red_tint
		yield(get_tree().create_timer(0.75), 'timeout')
		get_tree().reload_current_scene()
		$tint.color=blue_tint
		get_tree().paused=false
	
#	get_tree().reload_current_scene()
#	add_child(stage_reseter.instance())
func changeToLowPassMusic():
	print('Global: Changing to filtered music.')
	AudioServer.set_bus_mute(AudioServer.get_bus_index('bgm'), true)
	AudioServer.set_bus_mute(AudioServer.get_bus_index('bgm_lp'), false)
	print('Global: Done, the music was changed.')

func changeFromLowPassMusic():
	print('Global: Changing to unfiltered music.')
	AudioServer.set_bus_mute(AudioServer.get_bus_index('bgm'), false)
	AudioServer.set_bus_mute(AudioServer.get_bus_index('bgm_lp'), true)
	print('Global: Done, the music was changed.')

func vector_lerp(begin=Vector2(), end=Vector2(), alpha=0.1):
	var x=lerp(begin.x, end.x, alpha)
	var y=lerp(begin.y, end.y, alpha)
	return Vector2(x,y)