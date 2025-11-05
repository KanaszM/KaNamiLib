@tool
class_name DebugToolsCapsuleIndicator3D extends MeshInstance3D

#region Constants
const DIRECTION_MESH_SIZE: float = 0.5
#endregion

#region Exports
@export var color: Color = Color.WHITE: set = _set_color
@export var free_on_run: bool = true
#endregion

#region Private Variables
var _mesh: CapsuleMesh
var _material: StandardMaterial3D
var _direction: MeshInstance3D
var _direction_mesh: PlaneMesh
#endregion

#region Virtual Methods
func _ready() -> void:
	if not Engine.is_editor_hint() and free_on_run:
		queue_free()
		return
	
	_update()
#endregion

#region Private Methods
func _update() -> void:
	if _mesh == null:
		_mesh = CapsuleMesh.new()
		mesh = _mesh
	
	if _material == null:
		_material = StandardMaterial3D.new()
		_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		_mesh.material = _material
	
	_material.albedo_color = color
	
	if _direction == null:
		_direction = MeshInstance3D.new()
		_direction_mesh = PlaneMesh.new()
		
		_direction.mesh = _direction_mesh
		_direction_mesh.size = Vector2.ONE * DIRECTION_MESH_SIZE
		_direction_mesh.center_offset = Vector3(0.0, DIRECTION_MESH_SIZE, -DIRECTION_MESH_SIZE)
		_direction_mesh.material = _material
		
		add_child(_direction, false, Node.INTERNAL_MODE_BACK)
#endregion

#region Setter Methods
func _set_color(arg: Color) -> void:
	color = arg
	_update()
#endregion
