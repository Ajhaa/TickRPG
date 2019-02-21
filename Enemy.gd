extends Area2D

# class member variables go here, for example:
# var a = 2
export (int) var hitpoints
export (int) var damage
export (int) var cooldown
var max_cooldown

var can_attack = false
var path
var tile_coordinates = Vector2()


func _ready():
	# Called when the node is added to the scene for the first time.
	# Initialization here
	max_cooldown = cooldown
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
		
func attack(target):
	if cooldown > max_cooldown:
		cooldown = max_cooldown
	if cooldown == max_cooldown:
		target.hitpoints -= damage
		cooldown = 0