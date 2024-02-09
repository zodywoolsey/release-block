extends Control
@onready var button = $VBoxContainer/Button

signal play

func _ready():
	button.grab_focus()
	button.pressed.connect(func():
		conceal('play')
		get_viewport().gui_release_focus()
		)

func reveal():
	button.disabled = false
	var tween = create_tween()
	tween.tween_property(self, 'position', Vector2() ,1.0).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO)
	tween.tween_callback(func():
		button.grab_focus()
		)

func conceal(mode:String):
	button.disabled = true
	var tween = create_tween()
	tween.tween_property(self, 'position:x', -size.x ,1.0).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_EXPO)
	tween.tween_callback(_play)

func _play():
	play.emit()
