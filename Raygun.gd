extends Node

onready var audio_player = $AudioStreamPlayer
onready var rail_timer = $RailTimer
onready var camera = get_parent()
onready var line_render = $LineRenderer
var rail_ready = true;

# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
  pass # Replace with function body.

func shoot():
  var length = 1000
  var center = get_viewport().size/2
  var from = camera.project_ray_origin(center)
  var to = from + camera.project_ray_normal(center) * length

  var space = camera.get_world().direct_space_state

  var collision = space.intersect_ray(from, to, [self])

  if(collision):
    line_render.points = [camera.project_ray_origin(center), collision.position]
  else:
    line_render.points = [from, to]
  line_render.visible = true
  print(collision)

  rail_ready = false
  rail_timer.start()
  audio_player.play(0.0) 
  return

# Called every frame. 'delta' is the elapsed time since the previous frame.
# func _process(_delta):
  

func _physics_process(_delta):
  if Input.is_action_just_pressed("fire") && rail_ready:
    shoot()

func _on_RailTimer_timeout():
  line_render.visible = false
  rail_ready = true
  pass # Replace with function body.
