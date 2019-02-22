extends Area2D

# class member variables go here, for example:
# var a = 2
export (int) var hitpoints
export (int) var damage
export (int) var cooldown
export (int) var aggro_distance
export (PackedScene) var Hitsplat


var max_cooldown
var speed = 80/0.6
var should_move = false
var destination
var can_attack = false
var path
var tile_coordinates = Vector2()


func _ready():
	max_cooldown = cooldown

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
		
	position.x = stepify(position.x, 10.0)
	position.y = stepify(position.y, 10.0)
	
	should_move = true
	destination = path[0]

	path.remove(0)
	if path.size() == 0:
		path = null
		
func attack(target):
	if cooldown > max_cooldown:
		cooldown = max_cooldown
	if cooldown == max_cooldown:
		target.hitpoints -= damage
		cooldown = 0
		
func damage(amount):
	hitpoints -= amount
	var splat = Hitsplat.instance()
	splat.rect_position = global_position - Vector2(20,0)
	splat.text = str(amount)
	get_parent().add_child(splat)