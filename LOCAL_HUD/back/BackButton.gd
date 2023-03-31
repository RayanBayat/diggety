extends TextureButton

func _ready():
	connect("pressed", self, "_on_TextureButton_pressed")


func _on_TextureButton_pressed():
	GameLoader.back_to_client()
