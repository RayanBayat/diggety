extends Control
onready var game_timer = get_node("../../HUD/Control/GameTimer")

# Called when the node enters the scene tree for the first time.
func _ready():
	if GameLoader.first_time: 
		var inst = load("res://"+GameLoader.game_namespace+"/instructions.tscn")
		$inst.add_child(inst.instance())
		
		visible = true
		$Button.visible = false
	else: 
		visible = false
		if GameLoader.game_paused: 
			GameLoader.game_paused = false
	set_process(false)

func _process(_delta):
	if Input.is_action_pressed("ui_accept"):
		deactivate()

func _on_Button_pressed():
	deactivate()
	
func deactivate():
	visible = false
	set_process(false)
	#Here the game process should be started ... this is called once actaull data is provided by the sensor  
	GameLoader.game_started = true
	if GameLoader.first_time: 
		GameLoader.first_time = false
	game_timer.start()
	
#Currently instructions cannot be safelly restarted in project
#Tiem still active all the time 
func reactivate():
	set_process(true)
	$Button.visible = true
	visible = true
