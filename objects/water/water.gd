extends Area3D


# Called when the node enters the scene tree for the first time.
func _ready():
	
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_body_entered(body):
	if "current_state" in body:
		body.set_state(body.state_swim_normal)

func _on_body_exited(body):
	if "current_state" in body:
		body.set_state(body.state_normal)
