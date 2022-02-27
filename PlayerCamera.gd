extends Camera

onready var Player = get_parent()

export var camera_speed = 200

func look_updown(rotation = 0):
	var retval = self.get_rotation() + Vector3(rotation, 0, 0)
	retval.x = clamp(retval.x, PI/-2, PI/2)
	return retval

func look_leftright(rotation = 0):
	return Player.get_rotation() + Vector3(0,rotation,0)
# Called when the node enters the scene tree for the first time.
func _ready():
	set_process_input(true)
	self.fov = 100.0;
	pass # Replace with function body.

func _input(event):
	if not event is InputEventMouseMotion:
		return

	Player.set_rotation(look_leftright(event.relative.x/ -camera_speed))
	self.set_rotation(look_updown(event.relative.y / -camera_speed))


func _enter_tree():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	self.rotation.z = lerp_angle(self.rotation.z, deg2rad(-3 * Player.camera_tilt_direction), 0.01)
	return
