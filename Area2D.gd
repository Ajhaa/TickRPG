extends Area2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

var path

func _ready():
	# Called when the node is added to the scene for the first time.
	# Initialization here
	pass

#func _process(delta):
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
#	pass

func move():
	if !path:
		return
	position = path[0]
	path.remove(0)
	
	if path.size() == 0:
		path = null