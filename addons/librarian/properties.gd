@tool

const PROPERTY_BASE := "addons/librarian/"
const PROPERTY_LIBRARY_LOCATION := PROPERTY_BASE + "library_location"
const PROPERTY_LIBRARY_LOCATION__DEFAULT := "res://data/library"

## Definitions of editor settings.
##
## Settings should be defined as follows:
## name: Required by Godot for descriptions. Name of project setting.
## type: Required by Godot for descriptions. Variant.Type of project setting.
## hint: Optional for Godot descriptions. Variant.PropertyHit of project setting.
## hint_string: Optional for Godot descriptions. Hint for the project setting.
## basic: Required. Whether the property is basic (true) or advanced (false).
## internal: Required. Whether the property is internal (true) or exposed to user (false).
const definitions := [
    {
        "name": PROPERTY_LIBRARY_LOCATION,
        "type": TYPE_STRING,
        "hint_string": PROPERTY_LIBRARY_LOCATION__DEFAULT,
        "default": PROPERTY_LIBRARY_LOCATION__DEFAULT,
        "basic": true,
        "internal": false,
    }
]

static var settings := {}
static func _static_init() -> void:
    settings.clear()
    for def in definitions:
        var name = def["name"]
        if not ProjectSettings.has_setting(name):
            ProjectSettings.set_setting(name, def["default"])
        ProjectSettings.set_initial_value(name, def["default"])
        ProjectSettings.set_as_basic(name, def["basic"])
        ProjectSettings.set_as_internal(name, def["internal"])
        ProjectSettings.add_property_info(def)
        settings[name] = ProjectSettings.get_setting(name)

static func get_library_location() -> String:
    return settings.get(PROPERTY_LIBRARY_LOCATION, PROPERTY_LIBRARY_LOCATION__DEFAULT)
