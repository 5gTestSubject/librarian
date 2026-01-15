@tool
extends Container

func message_bus(): return get_node(preload("res://addons/librarian/scripts/message_bus.gd").AUTOLOAD_NODE_PATH)
const Util = preload("res://addons/librarian/utils.gd")

var loaded_file := ""
var _metadata: LibraryTableInfo

func get_metadata() -> LibraryTableInfo: return _metadata

func init_new(file_name: String, replace_metadata: bool, name: String) -> void:
    loaded_file = file_name
    _metadata = Util.load_metadata(loaded_file)
    _metadata.name = name
    %Spreadsheet.refresh_table(_metadata)

## Load the given table path into this spreadsheet using the given metadata.
func load_table(path: String, metadata: LibraryTableInfo) -> void:
    loaded_file = path
    _metadata = metadata
    name = _metadata.name
    %Spreadsheet.refresh_table(_metadata, Util.load_table(loaded_file, _metadata))

func save_table() -> void:
    Util.save_table(loaded_file, _metadata, %Spreadsheet.iter_entries())

func configure_table() -> void:
    %TableSettingsEditor.metadata = _metadata
    $TableSettingsWindow.visible = true

func add_row() -> void:
    %Spreadsheet.add_row()

func get_checked_rows_count() -> int:
    return %Spreadsheet.get_checked_rows_count()

func get_checked_rows() -> Array[int]:
    return %Spreadsheet.get_checked_rows()

func _on_new_table_configuration() -> void:
    var row_count = %Spreadsheet.get_spreadsheet_row_count()
    var ret = Util.compare_column_sets(_metadata.fields, %TableSettingsEditor.metadata.fields)
    var removed_old_fields = ret[0]
    var _new_fields = ret[1]
    var _identical_fields = ret[2]
    var altered_fields = ret[3]

    var sb: Array[String] = ["Are you sure you want to apply these changes over %d rows? This cannot be reverted." % row_count]
    if not removed_old_fields.is_empty():
        sb.append("The following columns and their %d values will be lost forever: %s."
            % [row_count, str(removed_old_fields.map(func(id): return _metadata.get_field_name_from_id(id)))])
    for altered_id in altered_fields:
        sb.append("The following columns will be altered and their %d values may be lost forever (if their values cannot be converted): %s."
            % [row_count, str(altered_fields.map(func(id): return _metadata.get_field_name_from_id(id)))])
    %AcceptConfigLabel.text = "\n\n".join(sb)

    $TableSettingsWindow.visible = false
    $AcceptConfigChangesConfirmation.visible = true
