extends Node

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

export (PackedScene) var Enemy
var enemies = []


func _ready():
#	$Player.connect("move", self, "_calculate_new_path")
	pass
	
	
func _input(event):
	if event is InputEventMouseButton:
		var pos = $TileMap.get_global_mouse_position()
		var target = $TileMap.world_to_map(pos)
		for enemy in enemies:
			if enemy.tile_coordinates == target:
				$Player.target = weakref(enemy)
			else:
				_calculate_new_path(pos)
				$Player.target = null


#func _process(delta):
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
#	pass
#func calculate_path_to_enemy():
#	_calculate_new_path($Player.target.position)
#	$Player.path.remove($Player.path.size()-1)

func _calculate_new_path(target):
	var path = $TileMap.get_path($Player.position, target)
	
	if path:
		path.remove(0)
		
		$Player.path = path
		
func _calculate_enemy_path():
	for enemy in enemies:
		var path = $TileMap.get_path(enemy.position, $Player.position)
	
		if path:
			path.remove(0)
			path.remove(path.size()-1)
		
			enemy.path = path

func _on_Timer_timeout():
	#print($Player.target)
	if enemies.size() < 1:
		create_enemy()
	_calculate_enemy_path()
	$Player.tile_coordinates = $TileMap.world_to_map($Player.position)
	$Player.cooldown += 1
	$Player.attacked = false
	
	var target
	if $Player.target:
		target = $Player.target.get_ref()
	
	if target:
		_calculate_new_path(target.position)
		$Player.path.remove($Player.path.size()-1)
	$Player.move()
	
	for enemy in enemies:
		#enemy.move()
		enemy.tile_coordinates = $TileMap.world_to_map(enemy.position)
		
	if target && next_to(target):
		$Player.attack(target)
		$Player.attacked = true
		
		if target.hitpoints <= 0:
			enemies.erase(target)
			target.queue_free()
				
	
func create_enemy():
	var enemy = Enemy.instance()
	add_child(enemy)
	enemy.position = Vector2(200, 40)
	enemies.append(enemy)
	
func next_to(enemy):
	if $Player.tile_coordinates.distance_squared_to(enemy.tile_coordinates) > 4:
		return false
	var x = $TileMap.get_path($Player.position, enemy.position).size()
	return x == 2
