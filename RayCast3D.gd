extends RayCast3D

var prevHover
var pressed := false

var clicked := false

@export var offset := Vector2()
@onready var cam = get_viewport().get_camera_3d()

func _input(event):
	if 'position' in event:
		target_position = cam.project_ray_normal(event.position+offset)*1000.0
	if event is InputEventScreenTouch:
		target_position = cam.project_ray_normal(event.position+offset)*1000.0
		force_raycast_update()
		if event.pressed:
			click()
			release()
			clicked = false

func _physics_process(delta):
	global_position = cam.global_position
	if is_colliding():
		var tmpcol = get_collider()
		if is_instance_valid(tmpcol) and tmpcol.has_method("laser_input"):
			if is_instance_valid(prevHover) and prevHover != tmpcol:
				prevHover.laser_input({
					'hovering': false,
					'pressed': false,
					'position': get_collision_point(),
					"action": "hover"
				})
			else:
				tmpcol.laser_input({
					'hovering': true,
					'pressed': false,
					"position": get_collision_point(),
					"action": "hover"
				})
			prevHover = tmpcol
		else:
			if is_instance_valid(prevHover) and prevHover.has_method("laser_input"):
				prevHover.laser_input({
					'hovering': false,
					'pressed': false,
					'position': get_collision_point(),
					"action": "hover"
				})
	else:
		if is_instance_valid(prevHover) and prevHover.has_method("laser_input") and prevHover.has_method('laser_input'):
			prevHover.laser_input({
				'hovering': false,
				'pressed': false,
				'position': get_collision_point(),
				'action': 'hover'
			})
			if pressed and prevHover.has_method('laser_input'):
				prevHover.laser_input({
					"position": get_collision_point(),
					"pressed": false,
					'action': 'click'
					})
			prevHover = null

func scrollup():
	if is_colliding():
		var tmpcol = get_collider()
		if is_instance_valid(tmpcol) and tmpcol.has_method("laser_input"):
			tmpcol.laser_input({
				"position": get_collision_point(),
				"pressed": true,
				"action": "scrollup"
				})
			tmpcol.laser_input({
				"position": get_collision_point(),
				"pressed": false,
				"action": "scrollup"
				})

func scrolldown():
	if is_colliding():
		var tmpcol = get_collider()
		if is_instance_valid(tmpcol) and tmpcol.has_method("laser_input"):
			tmpcol.laser_input({
				"position": get_collision_point(),
				"pressed": true,
				"action": "scrolldown"
				})
			tmpcol.laser_input({
				"position": get_collision_point(),
				"pressed": false,
				"action": "scrolldown"
				})

func click():
	if is_colliding():
		var tmpcol = get_collider()
		if is_instance_valid(tmpcol) and tmpcol.has_method("laser_input"):
			tmpcol.laser_input({
				"position": get_collision_point(),
				"pressed": true,
				'action': 'click'
				})
			pressed = true

func release():
	if is_colliding():
		var tmpcol = get_collider()
		if is_instance_valid(tmpcol) and tmpcol.has_method("laser_input"):
			tmpcol.laser_input({
				"position": get_collision_point(),
				"pressed": false,
				'action': 'click'
				})
			pressed = false
	elif is_instance_valid(prevHover):
		if prevHover.has_method("laser_input"):
			prevHover.laser_input({
				"position": get_collision_point(),
				"pressed": false,
				'action': 'click'
				})
