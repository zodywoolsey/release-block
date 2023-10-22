extends StaticBody3D
@onready var ray_cast_3d = $RayCast3D
@onready var animation_player = $AnimationPlayer

var timer = 0.0
var type := ''

func _ready():
	get_tree().create_timer(2).timeout.connect(_check_solved)
#	animation_player.speed_scale = .5
	animation_player.play_backwards("enter")

func _check_solved():
	if !ray_cast_3d.is_colliding():
		animation_player.play("remove")
		timer = 0
	get_tree().create_timer(.5).timeout.connect(_check_solved)

func laser_input(data:Dictionary):
	if !animation_player.is_playing():
		if !ray_cast_3d.is_colliding() and data.pressed:
			Input.vibrate_handheld(20)
			animation_player.play("remove")
		elif data.pressed:
			animation_player.play("stuck")

