extends Node3D

var starttime := 0.0

func get_bounding_box(node:Node=self) -> AABB:
	starttime = Time.get_unix_time_from_system()*1000
	return expand(node)

func expand(node:Node) -> AABB:
	var bounds
	for child in node.get_children():
		if bounds and 'position' in child:
			if child.position.length() > 500:
				child.free()
			else:
				bounds = bounds.expand(child.global_position)
		elif 'position' in child:
			bounds = AABB(child.position,Vector3())
		if is_instance_valid(child) and child.get_child_count()>0:
			get_bounding_box(child)
	if bounds:
		return bounds
	else:
		return AABB()
