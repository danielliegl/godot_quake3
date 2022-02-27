extends KinematicBody

var velocity = Vector3(0, 0, 0)
var direction = Vector3(0, 0, 0) # Used for animation

export var JUMP = 30
export var PLAYER_MOVE_SPEED = 70
export var MAX_ACCEL = 70
var friction = 5
var camera_tilt_direction = 0
var stop_speed = PLAYER_MOVE_SPEED / 3

onready var Camera = $Camera
onready var GRAVITY = ProjectSettings.get("physics/3d/default_gravity") * 0.2
onready var animation_tree = $character/AnimationTree


# Called when the node enters the scene tree for the first time.
func _ready():
  pass # Replace with function body.


#the direction the player intends to go to
func getWishdir():
  var forward_vector = Vector3(0, 0, 0)
  var right_vector = Vector3(0, 0, 0)

  if Input.is_action_pressed("ui_up") and not Input.is_action_pressed("ui_down"):
    forward_vector = Vector3(0,0,1)
  elif Input.is_action_pressed("ui_down") and not Input.is_action_pressed("ui_up"):
    forward_vector = Vector3(0,0,-1)
  
  if Input.is_action_pressed("ui_right") and not Input.is_action_pressed("ui_left"):
    right_vector = Vector3(-1,0,0)
  elif Input.is_action_pressed("ui_left") and not Input.is_action_pressed("ui_right"):
    right_vector = Vector3(1,0,0)
  
  
  return (forward_vector + right_vector).normalized().rotated(Vector3(0,1,0), self.rotation.y)

func accelerate(vel, wishdir, delta):
  var current_speed = vel.dot(wishdir)
  var addspeed = PLAYER_MOVE_SPEED - current_speed
  addspeed = max(min(addspeed, MAX_ACCEL * delta), 0)
  return vel + wishdir * addspeed
  
func apply_friction(delta):
  var speed = self.velocity.length()
  var control = 0
  if speed < 1:
    self.velocity.x = 0;
    self.velocity.z = 0;
    return
  
  var drop = 0
  #apply ground friction
  if(self.is_on_floor()):
    if(speed < stop_speed):
      control = stop_speed
    else:
      control = speed
    drop += control * friction * delta

  
  var new_speed = speed - drop

  if new_speed < 0:
    new_speed = 0

  new_speed = new_speed / speed

  self.velocity = self.velocity * new_speed
  return

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float):
  
  # save vertical velocity in temp variable, so we can add it back after
  # normalizing the direction of the x and z velocity so that going
  # diagonally isn't faster anymore
  
  var temp_y_velocity = self.velocity.y
  self.velocity.y = 0
  self.direction = Vector3(0,0,0)

  camera_tilt_direction = 0
  if Input.is_action_pressed("ui_left") and not Input.is_action_pressed("ui_right"):
    camera_tilt_direction = 1
  elif Input.is_action_pressed("ui_right") and not Input.is_action_pressed("ui_left"):
    camera_tilt_direction = -1
  
  self.velocity = accelerate(self.velocity, getWishdir(), delta) + Vector3(0, temp_y_velocity, 0)
  apply_friction(delta)
  $Camera/Speedometer.set_text("Speed: " + str(self.velocity.length()))
  pass


func _physics_process(_delta: float):
  var snap_vector = Vector3(0, -1, 0)

  if Input.is_action_pressed("action_jump"):
    if self.is_on_floor():
      self.velocity.y += JUMP
      # Disable snap to floor for the jumping frame
      snap_vector = Vector3(0, 0, 0)

  if self.is_on_floor():
    self.velocity -= Vector3(0, GRAVITY / 100, 0)
  else:
    self.velocity -= Vector3(0, GRAVITY, 0)

  self.velocity = self.move_and_slide_with_snap(
  self.velocity,
  snap_vector,
  Vector3(0,1,0),
  true)
