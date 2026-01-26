@tool
class_name LibraryTableInfo extends Resource

const ZERO_UUID := &"00000000-0000-0000-0000-000000000000"

@export var id := ZERO_UUID
@export var name := ""
@export var description := ""
@export var fields: Array[LibraryTableFieldInfo] = []

func get_field_name_from_id(id: StringName) -> String:
    for field in fields:
        if field.id == id:
            return field.name
    return ""

## Custom deep copy to work around Godot limitation.
## Currently, individual fields do not need this.
## 
## > Subresources inside Array and Dictionary properties are never duplicated.
## -- Resource.duplicate() documentation
func deep_copy() -> LibraryTableInfo:
    var new_table = LibraryTableInfo.new()
    new_table.id = id
    new_table.name = name
    for field in fields:
        new_table.fields.push_back(field.duplicate(true))
    return new_table

func to_dict() -> Dictionary:
    var ret := {}
    ret["id"] = id
    ret["name"] = name
    ret["description"] = description
    ret["fields"] = fields.map(func(field): return field.to_dict())
    return ret

static func from_dict(raw: Dictionary) -> LibraryTableInfo:
    var table = LibraryTableInfo.new()
    table.id = raw.get("id", ZERO_UUID)
    table.name = raw.get("name", "")
    table.description = raw.get("description", "")
    for raw_field in raw.get("fields", []):
        table.fields.push_back(LibraryTableFieldInfo.from_dict(raw_field))
    return table
