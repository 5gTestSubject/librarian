@tool

const Properties = preload("res://addons/librarian/properties.gd")
const Tag = preload("res://addons/librarian/scripts/tag.gd")
const Util = preload("res://addons/librarian/utils.gd")

const TAGS_LOCATION := ".ltags"

const VERSION_1_0 := "1.0"

static func get_location() -> String:
    return Util.path_combine(Properties.get_library_location(), TAGS_LOCATION)

static func load_tags() -> Dictionary[StringName, Tag]:
    var result: Dictionary[StringName, Tag] = {}
    var file := FileAccess.open(get_location(), FileAccess.READ)
    if not file:
        printerr("Failed to open \"%s\". Code %s." % [get_location(), FileAccess.get_open_error()])
        return result

    var file_version := file.get_line()
    if file_version != VERSION_1_0:
        printerr("Unrecognized library tags file version \"%s\"." % file_version)
        return result

    var row: PackedStringArray
    row = file.get_csv_line()
    while row.size() == 4:
        var tag = Tag.new(row[0], row[1], row[2])
        if Color.html_is_valid(row[3]):
            tag.color = Color.html(row[3])
        result[tag.id] = tag
        row = file.get_csv_line()
    match Array(row):
        []: pass
        [""]: pass
        _:
            printerr("Unexpected row in project tags table. Tag read aborted. %s." % [row])
    return result

static func save_tags(tags: Array[Tag]) -> bool:
    var file := FileAccess.open(get_location(), FileAccess.WRITE)
    if not file:
        printerr("Failed to open \"%s\". Code %s." % [get_location(), FileAccess.get_open_error()])
        return false

    if not file.store_line(VERSION_1_0):
        printerr("Failed to write project tags. Code %s." % FileAccess.get_open_error())
        return false

    for tag in tags:
        if not file.store_csv_line([
            tag.id,
            tag.name,
            tag.description,
            tag.color.to_html() if tag.color.a != 0.0 else ""
        ]):
            printerr("Failed to write project tags. Code %s." % FileAccess.get_open_error())
            return false
    return true
