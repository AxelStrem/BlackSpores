extends MeshInstance3D

var material : ShaderMaterial = null
var pro=0.0

func set_progress(p):
	material.set_shader_parameter("progress", p)
	if p>0.0:
		show()
	else:
		hide()

func _ready():
	material = self.get_active_material(0)

