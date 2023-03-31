extends Button

func _ready():
	connect("pressed", self, "_on_quit_pressed")
	GameLoader.connect("game_timeout", self, "_on_game_timeout")
	visible = false 
	
func _on_quit_pressed():
	visible = false
	disabled = true
	GameLoader.back_to_client()
	
func _on_game_timeout():
	visible = true
	var auto_timer = Timer.new()
	add_child(auto_timer)
	auto_timer.wait_time = 120 
	auto_timer.one_shot = true
	auto_timer.connect("timeout", self, "_on_quit_pressed")
	auto_timer.start()

