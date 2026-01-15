@tool
class_name LibraryTableInfo extends Resource

@export var id := -1
@export var name := ""
@export var description := ""
@export var _next_field_id := 0
@export var fields: Array[LibraryTableFieldInfo] = []

func get_field_name_from_id(id: int) -> String:
    for field in fields:
        if field.id == id:
            return field.name
    return ""

func get_new_field_id() -> int:
    var ret := _next_field_id
    _next_field_id += 1
    return ret

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
    ret["version"] = "pre-alpha"
    ret["id"] = id
    ret["name"] = name
    ret["description"] = description
    ret["next_field_id"] = _next_field_id
    ret["fields"] = fields.map(func(field): return field.to_dict())
    return ret

static func from_dict(raw: Dictionary) -> LibraryTableInfo:
    assert(raw["version"] == "1", "Unidentified metadata version %s" % raw["version"])
    var table = LibraryTableInfo.new()
    table.id = raw.get("id", -1)
    table.name = raw.get("name", "")
    table.description = raw.get("description", "")
    table._next_field_id = raw.get("next_field_id", 0)
    for raw_field in raw.get("fields", []):
        table.fields.push_back(LibraryTableFieldInfo.from_dict(raw_field))
    return table
