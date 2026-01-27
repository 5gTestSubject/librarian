@tool
extends Tree

const Util = preload("res://addons/librarian/utils.gd")

const COL_NAME := 0

const CONTEXT_MENU_OPERATIONS := {
    0: &"Open",
    2: &"Rename",
    3: &"Delete"
}

var _root: TreeItem
# var _favorites: TreeItem
var _library: TreeItem

var _watcher: DirectoryWatcher

@export var library_path: String = ""

@export var table_icon: Texture2D
# @export var favorites_icon: Texture2D

func _ready() -> void:
    _root = create_item()
    # _favorites = _root.create_child()
    _library = _root.create_child()

    # _favorites.set_text(COL_NAME, "Favorites")
    # _favorites.set_icon(COL_NAME, favorites_icon)

    _library.set_text(COL_NAME, "Library (%s)" % library_path)

    _watcher = DirectoryWatcher.new()
    add_child(_watcher)
    _watcher.add_scan_directory(library_path)
    _watcher.files_created.connect(_on_files_changed)
    _watcher.files_deleted.connect(_on_files_changed)

    refresh()

func refresh() -> void:
    var dir = DirAccess.open(library_path)
    for c in _library.get_children():
        _library.remove_child(c)
        c.free()
    for file_name in dir.get_files():
        if file_name.ends_with(".ltcsv"):
            var table_path = file_name.substr(0, file_name.length() - ".ltcsv".length())
            var item = _library.create_child()
            item.set_text(COL_NAME, table_path)
            item.set_icon(COL_NAME, table_icon)
            item.set_metadata(COL_NAME, table_path)

func _on_files_changed(_files: PackedStringArray) -> void:
    refresh()

func _on_item_activated() -> void:
    LibraryMessageBus.open_table.emit(get_selected().get_metadata(COL_NAME))

func _on_item_mouse_selected(mouse_position:Vector2, mouse_button_index:int) -> void:
    if mouse_button_index == MOUSE_BUTTON_RIGHT:
        var tree_item := get_selected()
        $ContextMenu.position = get_screen_position() + mouse_position
        $ContextMenu.popup()

func _on_context_menu_id_pressed(id: int) -> void:
    var tree_item := get_selected()
    match CONTEXT_MENU_OPERATIONS.get(id):
        &"Open":
            LibraryMessageBus.open_table.emit(tree_item.get_metadata(COL_NAME))
        &"Rename":
            printerr("TODO: implement spreadsheet rename")
        &"Delete":
            LibraryTableAccess.delete_table(tree_item.get_metadata(COL_NAME))
        _:
            printerr("Unrecognized context menu operation.")
