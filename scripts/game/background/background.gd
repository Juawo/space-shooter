extends ParallaxBackground

var scroll_speed = 120

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	scroll_offset.y += scroll_speed * delta
