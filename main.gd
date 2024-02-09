extends Node3D
@onready var camera_parent_y :Node3D= $CameraParentY
@onready var camera_parent_x :Node3D= $CameraParentY/CameraParentX
@onready var camera_3d :Camera3D= $CameraParentY/CameraParentX/Camera3D
@onready var menu = $menu

var mouse_speed := 5.0

var rotate_timer := 0.0
var rotating := false
var drag_velocity := Vector2()

var lasttime:int=0

func _input(event):
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

func init_board(new_size:=5):
	seed(2)
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
			for z in range(size):
				while lasttime+100 > Time.get_ticks_msec():
					pass
				lasttime = Time.get_ticks_msec()
				while !object_grid[x][y][z]:
					var go := false
					var choice :String
					while go == false:
						choice = options.pick_random()
						go = check_choice(choice,x,y,z)
					if choice:
						match choice:
							"right":
								var tmptile:Node3D = tile.instantiate()
								tmptile.hide()
								tile_parent.add_child(tmptile)
								tmptile.rotation_degrees = Vector3(0,-90,0)
								tmptile.position = Vector3(x,y,z)
								tmptile.type = 'right'
								object_grid[x][y][z] = choice
							"left":
								var tmptile:Node3D = tile.instantiate()
								tmptile.hide()
								tile_parent.add_child(tmptile)
								tmptile.rotation_degrees = Vector3(0,90,0)
								tmptile.position = Vector3(x,y,z)
								tmptile.type = 'left'
								object_grid[x][y][z] = choice
							"up":
								var tmptile:Node3D = tile.instantiate()
								tmptile.hide()
								tile_parent.add_child(tmptile)
								tmptile.rotation_degrees = Vector3(90,0,0)
								tmptile.position = Vector3(x,y,z)
								tmptile.type = 'up'
								object_grid[x][y][z] = choice
							"down":
								var tmptile:Node3D = tile.instantiate()
								tmptile.hide()
								tile_parent.add_child(tmptile)
								tmptile.rotation_degrees = Vector3(-90,0,0)
								tmptile.position = Vector3(x,y,z)
								tmptile.type = 'down'
								object_grid[x][y][z] = choice
							"forward":
								var tmptile:Node3D = tile.instantiate()
								tmptile.hide()
								tile_parent.add_child(tmptile)
								tmptile.rotation_degrees = Vector3(0,180,0)
								tmptile.position = Vector3(x,y,z)
								tmptile.type = 'forward'
								object_grid[x][y][z] = choice
							"backward":
								var tmptile:Node3D = tile.instantiate()
								tmptile.hide()
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
		go = solve_right(x,y,z,[])
	elif cell_value == 'left':
		go = solve_left(x,y,z,[])
	elif cell_value == 'up':
		go = solve_up(x,y,z,[])
	elif cell_value == 'down':
		go = solve_down(x,y,z,[])
	elif cell_value == 'forward':
		go = solve_forward(x,y,z,[])
	elif cell_value == 'backward':
		go = solve_backward(x,y,z,[])
	return go


func solve_right(x,y,z,origins:Array) -> bool:
	var out := false
	if Vector3(x,y,z) in origins:
		return false
	if x == size-1:
		out = true
	for a in size-x:
		if Vector3(x,y,z) not in origins:
			origins.append(Vector3(x,y,z))
		match object_grid[x+a][y][z]:
			'up':
				if solve_up(x+a,y,z,origins):
					out = true
				else:
					return false
			'down':
				if solve_down(x+a,y,z,origins):
					out = true
				else:
					return false
			'left':
				return false
			'right':
				if solve_right(x+a,y,z,origins):
					out = true
				else:
					return false
			'forward':
				if solve_forward(x+a,y,z,origins):
					out = true
				else:
					return false
			'backward':
				if solve_backward(x+a,y,z,origins):
					out = true
				else:
					return false
			null:
				out = true
	return out

func solve_left(x,y,z,origins:Array) -> bool:
	var out := false
	if Vector3(x,y,z) in origins:
		return false
	if x == 0:
		out = true
	for a in x+1:
		if Vector3(x,y,z) not in origins:
			origins.append(Vector3(x,y,z))
		match object_grid[x-a-1][y][z]:
			'up':
				if solve_up(x-a-1,y,z,origins):
					out = true
				else:
					return false
			'down':
				if solve_down(x-a-1,y,z,origins):
					out = true
				else:
					return false
			'left':
				return false
			'right':
				if solve_right(x-a-1,y,z,origins):
					out = true
				else:
					return false
			'forward':
				if solve_forward(x-a-1,y,z,origins):
					out = true
				else:
					return false
			'backward':
				if solve_backward(x-a-1,y,z,origins):
					out = true
				else:
					return false
			null:
				out = true
	return out

func solve_down(x,y,z,origins:Array) -> bool:
	var out := false
	if Vector3(x,y,z) in origins:
		return false
	if z == 0:
		out = true
	for a in y+1:
		if Vector3(x,y,z) not in origins:
			origins.append(Vector3(x,y,z))
		match object_grid[x][y-a-1][z]:
			'up':
				return false
			'down':
				if solve_down(x,y-a-1,z,origins):
					out = true
				else:
					return false
			'left':
				if solve_left(x,y-a-1,z,origins):
					out = true
				else:
					return false
			'right':
				if solve_right(x,y-a-1,z,origins):
					out = true
				else:
					return false
			'forward':
				if solve_forward(x,y-a-1,z,origins):
					out = true
				else:
					return false
			'backward':
				if solve_backward(x,y-a-1,z,origins):
					out = true
				else:
					return false
			null:
				out = true
	return out

func solve_up(x,y,z,origins:Array) -> bool:
	var out := false
	if Vector3(x,y,z) in origins:
		return false
	if y == size-1:
		out = true
	for a in size-y:
		if Vector3(x,y,z) not in origins:
			origins.append(Vector3(x,y,z))
		match object_grid[x][y+a][z]:
			'up':
				if solve_up(x,y+a,z,origins):
					out = true
				else:
					return false
			'down':
				return false
			'left':
				if solve_left(x,y+a,z,origins):
					out = true
				else:
					return false
			'right':
				if solve_right(x,y+a,z,origins):
					out = true
				else:
					return false
			'forward':
				if solve_forward(x,y+a,z,origins):
					out = true
				else:
					return false
			'backward':
				if solve_backward(x,y+a,z,origins):
					out = true
				else:
					return false
			null:
				out = true
	return out

func solve_forward(x,y,z,origins:Array) -> bool:
	var out := false
	if Vector3(x,y,z) in origins:
		return false
	if z == size-1:
		out = true
	for a in size-z:
		if Vector3(x,y,z) not in origins:
			origins.append(Vector3(x,y,z))
		match object_grid[x][y][z+a]:
			'up':
				if solve_up(x,y,z+a,origins):
					out = true
				else:
					return false
			'down':
				if solve_down(x,y,z+a,origins):
					out = true
				else:
					return false
			'left':
				if solve_left(x,y,z+a,origins):
					out = true
				else:
					return false
			'right':
				if solve_right(x,y,z+a,origins):
					out = true
				else:
					return false
			'forward':
				if solve_forward(x,y,z+a,origins):
					out = true
				else:
					return false
			'backward':
				return false
			null:
				out = true
	return out

func solve_backward(x,y,z,origins:Array) -> bool:
	var out := false
	if Vector3(x,y,z) in origins:
		return false
	if z == 0:
		out = true
	for a in z+1:
		if Vector3(x,y,z) not in origins:
			origins.append(Vector3(x,y,z))
		match object_grid[x][y][z-a-1]:
			'up':
				if solve_up(x,y,z-a-1,origins):
					out = true
				else:
					return false
			'down':
				if solve_down(x,y,z-a-1,origins):
					out = true
				else:
					return false
			'left':
				if solve_left(x,y,z-a-1,origins):
					out = true
				else:
					return false
			'right':
				if solve_right(x,y,z-a-1,origins):
					out = true
				else:
					return false
			'forward':
				return false
			'backward':
				if solve_backward(x,y,z-a-1,origins):
					out = true
				else:
					return false
			null:
				out = true
	return out
