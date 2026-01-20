@tool
class_name LibraryTableFieldInfo extends Resource

const ZERO_UUID := &"00000000-0000-0000-0000-000000000000"

const Util = preload("res://addons/librarian/utils.gd")

@export var id := ZERO_UUID
@export var name := ""
@export var description := ""
@export var type := Util.COL_TYPE_BOOL
@export var optional := false
@export var number_info := LibraryTableNumberFieldInfo.new()
@export var text_info := LibraryTableTextFieldInfo.new()

func get_default_value() -> Variant:
    Util.printwarn("TODO implement LibraryTableFieldInfo.get_default_value()")
    match type:
        Util.COL_TYPE_BOOL: return false
        Util.COL_TYPE_NUM: return 0.0
        Util.COL_TYPE_STRING: return ""
        Util.COL_TYPE_COLOR: return Color.WHITE
    return null

func equivalent_to(other: LibraryTableFieldInfo) -> bool:
    return (
        other != null &&
        id == other.id &&
        name == other.name &&
        description == other.description &&
        type == other.type &&
        optional == other.optional &&
        (number_info == null if other.number_info == null else number_info.equivalent_to(other.number_info)) &&
        (text_info == null if other.text_info == null else text_info.equivalent_to(other.text_info))
    )

func to_dict() -> Dictionary:
    var ret := {}
    ret["id"] = id
    ret["name"] = name
    ret["description"] = description
    ret["type"] = type
    ret["optional"] = optional
    match type:
        Util.COL_TYPE_BOOL:
            pass
        Util.COL_TYPE_NUM:
            ret["number_info"] = number_info.to_dict()
        Util.COL_TYPE_STRING:
            ret["text_info"] = text_info.to_dict()
    return ret

static func from_dict(raw: Dictionary) -> LibraryTableFieldInfo:
    var field = LibraryTableFieldInfo.new()
    field.id = raw.get("id", ZERO_UUID)
    field.name = raw.get("name", "")
    field.description = raw.get("description", "")
    field.type = raw.get("type", Util.COL_TYPE_BOOL)
    field.optional = raw.get("optional", false)
    match field.type:
        Util.COL_TYPE_BOOL:
            field.number_info = LibraryTableNumberFieldInfo.new()
            field.text_info = LibraryTableTextFieldInfo.new()
        Util.COL_TYPE_NUM:
            if raw.has("number_info"):
                field.number_info = LibraryTableNumberFieldInfo.from_dict(
                    raw.get("number_info", {}))
            else:
                field.number_info = LibraryTableNumberFieldInfo.new()
            field.text_info = LibraryTableTextFieldInfo.new()
        Util.COL_TYPE_STRING:
            if raw.has("text_info"):
                field.text_info = LibraryTableTextFieldInfo.from_dict(
                    raw.get("text_info", {}))
            else:
                field.text_info = LibraryTableTextFieldInfo.new()
            field.number_info = LibraryTableNumberFieldInfo.new()
    return field
