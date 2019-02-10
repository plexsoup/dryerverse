extends Camera2D

# Declare member variables here. Examples:
# var a = 2

#onready var ViewTarget = get_node("../Crane/Muzzle")
export (bool) var ZoomAllowed = true
export (float) var ZoomSpeed = 0.3
var InitialZoom = Vector2(1.6, 1.6)
var DesiredZoom = Vector2(1.6, 1.6)



	
func _input(event):
	#print(self.name, " zoom == ", get_zoom() )
	if event.is_action_pressed("zoom_in") == true and ZoomAllowed == true:
		#self.zoom -= Vector2(zoomSpeed, zoomSpeed)
		DesiredZoom -= Vector2(ZoomSpeed, ZoomSpeed)
		if DesiredZoom.x < 0.1:
			DesiredZoom = Vector2(0.1, 0.1)
			
		self.zoom = DesiredZoom
	elif event.is_action_pressed("zoom_out") == true and ZoomAllowed == true:
		#self.zoom += Vector2(zoomSpeed, zoomSpeed)
		DesiredZoom += Vector2(ZoomSpeed, ZoomSpeed)
		self.zoom = DesiredZoom
		if DesiredZoom.x > 8.0:
			DesiredZoom = Vector2(8, 8)



