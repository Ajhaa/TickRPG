extends Node

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

export (PackedScene) var Enemy
var enemies = []
var player
var calculated = false


func _ready():
	player = $Player
	pass
	
	
func _input(event):
	if event is InputEventMouseButton:
		if event.is_pressed():
			if event.button_index == BUTTON_LEFT:
				var pos = $TileMap.get_global_mouse_position()
				var target = $TileMap.world_to_map(pos)
				for enemy in enemies:
					if enemy.tile_coordinates == target:
						$Player.target = weakref(enemy)
						break
					else:
						_calculate_new_path(pos)
						$Player.target = null
			if event.button_index == BUTTON_WHEEL_UP:
				$Player.zoom(-0.1)
			if event.button_index == BUTTON_WHEEL_DOWN:
				$Player.zoom(0.1)


func _process(delta):
	if !calculated:
		_calculate_enemy_path()
	if player.target:
		if player.target.get_ref():
			if player.path:
				_calculate_new_path(player.target.get_ref().position)
				player.path.remove($Player.path.size()-1)


func _calculate_new_path(target):
	var path = $TileMap.get_path($Player.position, target)
	
	if path:
		path.remove(0)
		
		$Player.path = path
		
func _calculate_enemy_path():
	for enemy in enemies:
		if !aggro(enemy):
			continue
		var path = $TileMap.get_path(enemy.position, $Player.position)
	
		if path:
			path.remove(0)
			path.remove(path.size()-1)
		
			enemy.path = path
	calculated = true

func _on_Timer_timeout():
	print("ENEMIES: " + str(enemies.size()))
	if enemies.size() < 8:
		create_enemy()
		
	player.tile_coordinates = $TileMap.world_to_map($Player.position)
	player.cooldown += 1
	player.attacked = false
	
	var target
	if $Player.target:
		target = player.target.get_ref()
	
	for enemy in enemies:
		var tile_id = $TileMap._get_id_for_point($TileMap.world_to_map(enemy.position))
		$TileMap.astar.set_point_weight_scale(tile_id, 1)
		
		enemy.move()
		
		tile_id = $TileMap._get_id_for_point($TileMap.world_to_map(enemy.position))
		$TileMap.astar.set_point_weight_scale(tile_id, 3)
		
		enemy.tile_coordinates = $TileMap.world_to_map(enemy.position)
		
	calculated = false
		
	if target && next_to(target):
		player.attack(target)
		player.attacked = true
		if target.hitpoints <= 0:
			enemies.erase(target)
			target.queue_free()
			
	player.move()
	if target:
		player.path = null
	
func create_enemy():
	var enemy = Enemy.instance()
	add_child(enemy)
	var possible_positions = $TileMap.get_used_cells()
	randomize()
	var spawn_position = possible_positions[randi()%possible_positions.size()]
	
	enemy.position = $TileMap.map_to_world(spawn_position) + Vector2(40, 40)
	enemies.append(enemy)
	
func aggro(enemy):
	return player.tile_coordinates.distance_squared_to(enemy.tile_coordinates) <= pow(enemy.aggro_distance, 2)
		
	
func next_to(enemy):
	if player.tile_coordinates.distance_squared_to(enemy.tile_coordinates) > 4:
		return false
	var x = $TileMap.get_path($Player.position, enemy.position).size()
	return x == 2
