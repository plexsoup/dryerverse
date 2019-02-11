extends StaticBody2D

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	self.add_to_group("barriers")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	set_global_position(get_global_position() + Vector2(0.0, -1.0) * delta)

