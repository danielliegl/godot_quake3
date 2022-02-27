extends KinematicBody

var velocity = Vector3(0, 0, 0)
var direction = Vector3(0, 0, 0) # Used for animation

export var JUMP = 30
var wishJump = false
export var PLAYER_MOVE_SPEED = 40

var run_acceleration = 14
var run_deacceleration = 10

var air_acceleration = 2

var friction = 12
var snap_vector = Vector3(0, -1, 0)

onready var Camera = $Camera
var camera_tilt_direction = 0

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

func accelerate(wishspeed, wishdir, accel, delta):
  var current_speed = self.velocity.dot(wishdir)
  var addspeed = wishspeed - current_speed
  if(addspeed <= 0):
    return self.velocity
  var accelspeed = accel * delta * wishspeed
  if(accelspeed > addspeed):
    accelspeed = addspeed
  
  return self.velocity + wishdir * accelspeed

  
func apply_friction(delta):
  var speed = self.velocity.length()
  var control = 0
  var new_speed = 0

  if speed < 0.3:
    self.velocity.x = 0;
    self.velocity.z = 0;
    return self.velocity
  
  var drop = 0
  #apply ground friction
  if(self.is_on_floor()):
    if(speed < run_deacceleration):
      control = run_deacceleration
    else:
      control = speed
    drop = control * friction * delta
  
  new_speed = speed - drop

  if new_speed < 0:
    new_speed = 0
  if speed > 0:
    new_speed = new_speed / speed

  self.velocity = self.velocity * new_speed
  return
  

func groundMove(delta):

  var wishdir = getWishdir()
  var wishvel = wishdir.length() * PLAYER_MOVE_SPEED
  var temp_y_velocity = self.velocity.y
  self.velocity.y = 0

  if(!wishJump):
    apply_friction(delta)

  self.velocity = accelerate(wishvel, wishdir, run_acceleration, delta) + Vector3(0, temp_y_velocity, 0)

  if(wishJump):
    self.velocity += Vector3(0,1,0) * JUMP
    snap_vector = Vector3(0,0,0)
    wishJump = false

  return

func airMove(delta):
  var wishdir = getWishdir()
  var wishvel = wishdir.length() * PLAYER_MOVE_SPEED
  var temp_y_velocity = self.velocity.y
  self.velocity.y = 0

  self.velocity = accelerate(wishvel, wishdir, air_acceleration, delta) + Vector3(0, temp_y_velocity, 0)

  return

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float):

  if Input.is_action_just_pressed("action_jump"):
    wishJump = true

  self.direction = Vector3(0,0,0)

  # handle camera tilt
  camera_tilt_direction = 0
  if Input.is_action_pressed("ui_left") and not Input.is_action_pressed("ui_right"):
    camera_tilt_direction = -1
  elif Input.is_action_pressed("ui_right") and not Input.is_action_pressed("ui_left"):
    camera_tilt_direction = 1
  
  # move functions depending on being grounded
  if self.is_on_floor():
    groundMove(delta)
  else:
    airMove(delta)
  
  # speedometer
  var temp_y_velocity = self.velocity.y
  self.velocity.y = 0
  $Camera/Speedometer.set_text("Speed: " + str(self.velocity.length()))
  self.velocity.y = temp_y_velocity
  pass

func _physics_process(_delta: float):

  # apply gravity
  if self.is_on_floor():
    self.velocity -= Vector3(0, GRAVITY / 100, 0)
  else:
    self.velocity -= Vector3(0, GRAVITY, 0)
      
  self.velocity = self.move_and_slide_with_snap(
  self.velocity,
  snap_vector,
  Vector3(0,1,0),
  true)
  
  # reset snap vector
  snap_vector = Vector3(0, -1, 0)
