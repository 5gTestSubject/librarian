@tool
class_name LibraryTableTextFieldInfo extends Resource

const Util = preload("res://addons/librarian/utils.gd")

@export var placeholder_text := ""

func equivalent_to(other: LibraryTableTextFieldInfo) -> bool:
    return (
        other != null &&
        placeholder_text == other.placeholder_text
    )

func to_dict() -> Dictionary:
    var ret = {}
    ret["placeholder_text"] = placeholder_text
    return ret

static func from_dict(raw: Dictionary) -> LibraryTableTextFieldInfo:
    var field = LibraryTableTextFieldInfo.new()
    field.placeholder_text = raw.get("placeholder_text", "")
    return field
