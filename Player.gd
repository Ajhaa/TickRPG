extends KinematicBody2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"
signal move

export (PackedScene) var Hitsplat

var can_attack = false
var target
var path
var tile_coordinates = Vector2()
export (int) var hitpoints
export (int) var damage
export (int) var cooldown
var max_cooldown
var attacked = false
var speed = 80/0.6
var destination
var should_move = false

func _ready():
	max_cooldown = cooldown
	
	
# func _input(event):
#	if event is InputEventMouseButton:
#		var x = event.position.x
#		var y = event.position.y
#		target = Vector2(x, y)
#		emit_signal("move")

func _process(delta):
	if should_move:
		var mvmt = destination - position
		mvmt.x = sign(mvmt.x)*1 if mvmt.x != 0 else 0
		mvmt.y = sign(mvmt.y)*1 if mvmt.y != 0 else 0
		position += mvmt * speed * delta
		
		
		


func move():
	if !path:
		should_move = false
		destination = null
		return
	should_move = true
	destination = path[0]
	position.x = stepify(position.x, 10.0)
	position.y = stepify(position.y, 10.0)
	print(position)
	path.remove(0)
	if path.size() == 0:
		path = null

func attack(target):
	if cooldown > max_cooldown:
		cooldown = max_cooldown
	if cooldown == max_cooldown:
		target.damage(damage)
		cooldown = 0
		
func zoom(amount):
	if amount < 0:
		if $Camera.zoom.x < 0.5:
			return
	if amount > 0:
		if $Camera.zoom.x > 2:
			return
			
	$Camera.zoom += Vector2(amount, amount)
	
