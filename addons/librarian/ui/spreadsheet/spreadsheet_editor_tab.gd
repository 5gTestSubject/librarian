@tool
extends Container

const TableAccess = preload("res://addons/librarian/scripts/io/table_access.gd")
const Util = preload("res://addons/librarian/utils.gd")

var loaded_path := ""
var metadata: LibraryTableInfo

## Load the given table path into this spreadsheet using the given metadata.
func load_content(table_path: String) -> void:
    loaded_path = table_path
    var reader = TableAccess.read_table(table_path)
    metadata = reader.metadata
    name = metadata.name
    %Spreadsheet.reset_table(metadata)
    LibraryMessageBus.main_screen_table_changed.emit(metadata)
    var data_row: Array = reader.read()
    while not data_row.is_empty() and not (data_row.size() == 1 and data_row[0] == null):
        %Spreadsheet.add_row(data_row)
        data_row = reader.read()

func save_content(flush_every: int = -1) -> void:
    var writer = TableAccess.get_table_writer(loaded_path) #, metadata, %Spreadsheet.iter_entries())
    writer.open(metadata)
    for tup in Util.EnumerateIterator.new(%Spreadsheet.iter_entries()):
        writer.write(tup[1])
        if flush_every > 0 and (tup[0] + 1) % flush_every == 0:
            writer.flush()
    writer.close()

func add_row() -> void:
    %Spreadsheet.add_row([])

func delete_selected() -> void:
    var checked_rows = %Spreadsheet.get_checked_rows()
    checked_rows.sort()
    checked_rows.reverse()
    for i in checked_rows:
        LibraryMessageBus.row_deleted.emit(%Spreadsheet.get_metadata().id, i)

func on_editor_tab_selected() -> void:
    LibraryMessageBus.main_screen_table_changed.emit(metadata)
