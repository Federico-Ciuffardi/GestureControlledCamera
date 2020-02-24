extends Camera2D

# Configuration
export(float) var MAX_ZOOM = 4
export(float) var MIN_ZOOM = 0.16 

export(int,"disabled","pinch") var zoom_gesture = 1
export(int,"disabled","twist") var rotation_gesture = 1
export(int,"disabled","single_drag","multi_drag") var movement_gesture = 2

func _ready():
	if zoom_gesture == 1: InputManager.connect("pinch",self,"zoom")
	
	if rotation_gesture == 1: InputManager.connect("twist",self,"rotate")
	
	if   movement_gesture == 1: InputManager.connect("single_drag",self,"move")
	elif movement_gesture == 2: InputManager.connect("multi_drag",self,"move")

# Given a a position on the camera returns to the corresponding global position
func camera2global(position):
	var camera_center = global_position + offset
	var from_camera_center_pos = position - get_camera_center_offset()
	return camera_center + (from_camera_center_pos*zoom).rotated(rotation)

func move(event):
	offset -= (event.relative*zoom).rotated(rotation)
	
func zoom(event):
	var li = event.distance
	var lf = event.distance + event.relative
	var zi = zoom.x
	
	var zf = (li*zi)/lf
	if zf == 0: return
	var zd = zf - zi
	
	if zf <= MIN_ZOOM and sign(zd) < 0:
		zf =MIN_ZOOM
		zd = zf - zi
	elif zf >= MAX_ZOOM and sign(zd) > 0:
		zf = MAX_ZOOM
		zd = zf - zi
	
	var from_camera_center_pos = event.position - get_camera_center_offset()
	offset -= (from_camera_center_pos*zd).rotated(rotation)
	zoom = zf*Vector2.ONE

func rotate(event):
	var fccp = (event.position - get_camera_center_offset()) # from_camera_center_pos = fccp
	var fccp_op_rot =  -fccp.rotated(event.relative)
	offset -= ((fccp_op_rot + fccp)*zoom).rotated(rotation-event.relative)
	rotation -= event.relative

func get_camera_center_offset():
	if anchor_mode == ANCHOR_MODE_FIXED_TOP_LEFT:
		return Vector2.ZERO
	elif anchor_mode ==  ANCHOR_MODE_DRAG_CENTER:
		return get_camera_size()/2

func get_camera_size():
	return get_viewport().get_visible_rect().size