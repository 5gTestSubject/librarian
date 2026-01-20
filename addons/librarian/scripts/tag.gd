@tool
extends Resource

const ZERO_UUID := &"00000000-0000-0000-0000-000000000000"

@export var id: StringName
@export var name: String
@export var description: String
@export var color: Color

func _init(id: StringName = ZERO_UUID, name: String = "", description: String = "", color: Color = Color(0, 0, 0, 0)) -> void:
    self.id = id
    self.name = name
    self.description = description
    self.color = color
