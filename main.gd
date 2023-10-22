extends Node3D
@onready var camera_parent_y :Node3D= $CameraParentY
@onready var camera_parent_x :Node3D= $CameraParentY/CameraParentX
@onready var camera_3d :Camera3D= $CameraParentY/CameraParentX/Camera3D
@onready var menu = $menu

var mouse_speed := 5.0

var rotate_timer := 0.0
var rotating := false
var drag_velocity := Vector2()

func _input(event):
	if event is InputEventMagnifyGesture:
		print(event)
	if event is InputEventKey and event.pressed and event.keycode == KEY_R:
		for child in tile_parent.get_children():
			child.queue_free()
		init_board()
	if event is InputEventScreenDrag:
		rotating = true
		if rotate_timer > .05:
			drag_velocity = event.relative
			camera_parent_x.rotate_object_local(Vector3.RIGHT, -event.relative.y/(1000.0/mouse_speed) )
			camera_parent_y.rotate_object_local(Vector3.UP, (-event.relative.x/(1000.0/mouse_speed)) )
			if camera_parent_x.rotation_degrees.x > 45.0:
				camera_parent_x.rotation_degrees.x = 45.0
			if camera_parent_x.rotation_degrees.x < -45.0:
				camera_parent_x.rotation_degrees.x = -45.0
	elif event is InputEventScreenTouch:
		rotating = false
		rotate_timer = 0.0

func _process(delta):
	var tmppos = tile_parent.get_bounding_box(tile_parent).get_center()
	camera_parent_y.global_position.x = lerpf(camera_parent_y.global_position.x,tmppos.x,.02)
	camera_parent_y.global_position.y = lerpf(camera_parent_y.global_position.y,tmppos.y,.02)
	camera_parent_y.global_position.z = lerpf(camera_parent_y.global_position.z,tmppos.z,.02)
	if get_viewport().size.x > get_viewport().size.y:
		camera_3d.position.z = size*2.0
	else:
		camera_3d.position.z = size*2.5
	if rotating:
		rotate_timer += delta
#	else:
#		camera_parent_x.rotate_object_local(Vector3.RIGHT, -drag_velocity.y/(1000.0/mouse_speed) )
#		camera_parent_y.rotate_object_local(Vector3.UP, (-drag_velocity.x/(1000.0/mouse_speed)) )
#		if camera_parent_x.rotation_degrees.x > 45.0:
#			camera_parent_x.rotation_degrees.x = 45.0
#		if camera_parent_x.rotation_degrees.x < -45.0:
#			camera_parent_x.rotation_degrees.x = -45.0

@onready var object_grid:Array
@onready var tile_parent :Node3D= $TileParent

var options := ['right','left','up','down','forward','backward']
var size := 5
var tile :PackedScene= preload("res://tile.tscn")

func _ready():
	menu.play.connect(init_board)
	tile_parent.child_exiting_tree.connect(func(node):
		if tile_parent.get_child_count() == 1:
			menu.reveal()
		)
#	var raysize = 10
#	for x in range(raysize):
#		for y in range(raysize):
#			var tmp = load("res://ray_cast_3d.tscn").instantiate()
#			add_child(tmp)
#			tmp.offset = Vector2((x*20.0)-((raysize/2.0)*20.0),(y*20.0)-((raysize/2.0)*20.0))
#	init_board()

func init_board():
#	seed(2)
	randomize()
#	size = randi_range(4, 10)
	tile_parent.position = Vector3(-float(size)/2.0,-float(size)/2.0,-float(size)/2.0)
	object_grid.resize(size)
	for i in size:
		object_grid[i] = Array()
		object_grid[i].resize(size)
		for a in size:
			object_grid[i][a] = Array()
			object_grid[i][a].resize(size)
	for x in range(size):
		for y in range(size):
			await get_tree().process_frame
			for z in range(size):
				while !object_grid[x][y][z]:
					var choice :String= options.pick_random()
					if check_choice(choice, x, y, z):
						match choice:
							"right":
								var tmptile:Node3D = tile.instantiate()
								tile_parent.add_child(tmptile)
								tmptile.rotation_degrees = Vector3(0,-90,0)
								tmptile.position = Vector3(x,y,z)
								tmptile.type = 'right'
								object_grid[x][y][z] = choice
							"left":
								var tmptile:Node3D = tile.instantiate()
								tile_parent.add_child(tmptile)
								tmptile.rotation_degrees = Vector3(0,90,0)
								tmptile.position = Vector3(x,y,z)
								tmptile.type = 'left'
								object_grid[x][y][z] = choice
							"up":
								var tmptile:Node3D = tile.instantiate()
								tile_parent.add_child(tmptile)
								tmptile.rotation_degrees = Vector3(90,0,0)
								tmptile.position = Vector3(x,y,z)
								tmptile.type = 'up'
								object_grid[x][y][z] = choice
							"down":
								var tmptile:Node3D = tile.instantiate()
								tile_parent.add_child(tmptile)
								tmptile.rotation_degrees = Vector3(-90,0,0)
								tmptile.position = Vector3(x,y,z)
								tmptile.type = 'down'
								object_grid[x][y][z] = choice
							"forward":
								var tmptile:Node3D = tile.instantiate()
								tile_parent.add_child(tmptile)
								tmptile.rotation_degrees = Vector3(0,180,0)
								tmptile.position = Vector3(x,y,z)
								tmptile.type = 'forward'
								object_grid[x][y][z] = choice
							"backward":
								var tmptile:Node3D = tile.instantiate()
								tile_parent.add_child(tmptile)
								tmptile.rotation_degrees = Vector3(0,0,0)
								tmptile.position = Vector3(x,y,z)
								tmptile.type = 'backward'
								object_grid[x][y][z] = choice
							_:
								pass

func check_choice(cell_value, x, y, z) -> bool:
	var go := false
	if cell_value == 'right':
		return solve_right(x,y,z,[])
	elif cell_value == 'left':
		return solve_left(x,y,z,[])
	elif cell_value == 'up':
		return solve_up(x,y,z,[])
	elif cell_value == 'down':
		return solve_down(x,y,z,[])
	elif cell_value == 'forward':
		return solve_forward(x,y,z,[])
	elif cell_value == 'backward':
		return solve_backward(x,y,z,[])
	return go


func solve_right(x,y,z,origins:Array) -> bool:
	var out := false
	if Vector3(x,y,z) in origins:
		return false
	if x == size-1:
		return true
	for a in size-x:
		if Vector3(x,y,z) not in origins:
			origins.append(Vector3(x,y,z))
		match object_grid[x+a][y][z]:
			'up':
				return solve_up(x+a,y,z,origins)
			'down':
				return solve_down(x+a,y,z,origins)
			'left':
				return false
			'right':
				return solve_right(x+a,y,z,origins)
			'forward':
				return solve_forward(x+a,y,z,origins)
			'backward':
				return solve_backward(x+a,y,z,origins)
#			_:
#				return true
	return false

func solve_left(x,y,z,origins:Array) -> bool:
	if Vector3(x,y,z) in origins:
		return false
	if x == 0:
		return true
	for a in x+1:
		if Vector3(x,y,z) not in origins:
			origins.append(Vector3(x,y,z))
		match object_grid[x-a-1][y][z]:
			'up':
				return solve_up(x-a-1,y,z,origins)
			'down':
				return solve_down(x-a-1,y,z,origins)
			'left':
				return false
			'right':
				return solve_right(x-a-1,y,z,origins)
			'forward':
				return solve_forward(x-a-1,y,z,origins)
			'backward':
				return solve_backward(x-a-1,y,z,origins)
#			_:
#				return true
	return false

func solve_down(x,y,z,origins:Array) -> bool:
	if Vector3(x,y,z) in origins:
		return false
	if z == 0:
		return true
	for a in y+1:
		if Vector3(x,y,z) not in origins:
			origins.append(Vector3(x,y,z))
		match object_grid[x][y-a-1][z]:
			'up':
				return false
			'down':
				return solve_down(x,y-a-1,z,origins)
			'left':
				return solve_left(x,y-a-1,z,origins)
			'right':
				return solve_right(x,y-a-1,z,origins)
			'forward':
				return solve_forward(x,y-a-1,z,origins)
			'backward':
				return solve_backward(x,y-a-1,z,origins)
#			_:
#				return true
	return false

func solve_up(x,y,z,origins:Array) -> bool:
	if Vector3(x,y,z) in origins:
		return false
	if y == size-1:
		return true
	for a in size-y:
		if Vector3(x,y,z) not in origins:
			origins.append(Vector3(x,y,z))
		match object_grid[x][y+a][z]:
			'up':
				return solve_up(x,y+a,z,origins)
			'down':
				return false
			'left':
				return solve_left(x,y+a,z,origins)
			'right':
				return solve_right(x,y+a,z,origins)
			'forward':
				return solve_forward(x,y+a,z,origins)
			'backward':
				return solve_backward(x,y+a,z,origins)
#			_:
#				return true
	return false

func solve_forward(x,y,z,origins:Array) -> bool:
	if Vector3(x,y,z) in origins:
		return false
	if z == size-1:
		return true
	for a in size-z:
		if Vector3(x,y,z) not in origins:
			origins.append(Vector3(x,y,z))
		match object_grid[x][y][z+a]:
			'up':
				return solve_up(x,y,z+a,origins)
			'down':
				return solve_down(x,y,z+a,origins)
			'left':
				return solve_left(x,y,z+a,origins)
			'right':
				return solve_right(x,y,z+a,origins)
			'forward':
				return solve_forward(x,y,z+a,origins)
			'backward':
				return false
#			_:
#				return true
	return false

func solve_backward(x,y,z,origins:Array) -> bool:
	if Vector3(x,y,z) in origins:
		return false
	if z == 0:
		return true
	for a in z+1:
		if Vector3(x,y,z) not in origins:
			origins.append(Vector3(x,y,z))
		match object_grid[x][y][z-a-1]:
			'up':
				return solve_up(x,y,z-a-1,origins)
			'down':
				return solve_down(x,y,z-a-1,origins)
			'left':
				return solve_left(x,y,z-a-1,origins)
			'right':
				return solve_right(x,y,z-a-1,origins)
			'forward':
				return false
			'backward':
				return solve_backward(x,y,z-a-1,origins)
#			_:
#				return true
	return false
