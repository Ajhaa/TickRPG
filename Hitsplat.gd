extends Label

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

func _ready():
	$Timer.start()

func _process(delta):
	rect_position.y -= 80 * delta


func _on_Timer_timeout():
	queue_free()
