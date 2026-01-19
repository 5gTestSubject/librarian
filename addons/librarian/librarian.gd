@tool
extends EditorPlugin

const MessageBus = preload("res://addons/librarian/scripts/message_bus.gd")
const Util = preload("res://addons/librarian/utils.gd")

var main_screen_catalog: Control
var library_dock: Control
var table_dock: Control

func _enable_plugin() -> void:
    _register_message_bus()

func _disable_plugin() -> void:
    remove_autoload_singleton(MessageBus.AUTOLOAD_NAME)

func _enter_tree() -> void:
    _register_message_bus()
    main_screen_catalog = load("res://addons/librarian/ui/main_screen.tscn").instantiate()
    library_dock = load("res://addons/librarian/ui/library_dock.tscn").instantiate()
    table_dock = load("res://addons/librarian/ui/table_dock.tscn").instantiate()
    EditorInterface.get_editor_main_screen().add_child(main_screen_catalog)
    add_control_to_dock(DockSlot.DOCK_SLOT_LEFT_UR, table_dock)
    add_control_to_dock(DockSlot.DOCK_SLOT_LEFT_BR, library_dock)
    _make_visible(false)

func _exit_tree() -> void:
    main_screen_catalog.queue_free()
    remove_control_from_docks(library_dock)
    remove_control_from_docks(table_dock)
    library_dock.queue_free()
    table_dock.queue_free()

#region Plugin Overrides
func _has_main_screen() -> bool:
    return true

func _get_plugin_name() -> String:
    return Util.MAIN_SCREEN_NAME

func _make_visible(visible: bool) -> void:
    if main_screen_catalog:
        main_screen_catalog.visible = visible
#endregion

func _register_message_bus() -> void:
    # Autoloads are documented as being managed in _enable_plugin() and _disable_plugin().
    # These methods are not called before _enter_tree(), which sets up the GUI screens for the editor.
    # If any of those GUI scenes need access to that autoload, they will fail to find it when the plugin is enabled.
    #
    # Therefore we must setup autoload on _enter_tree(), but we do not want to attempt to add another autoload on
    # every editor startup. So we check to see if the node already exists in the editor's scene tree and register
    # the autoload if it doesn't. It seems to be guaranteed the existing autoloads will already be present before
    # this plugin enters the tree.
    if not get_node_or_null(MessageBus.AUTOLOAD_NODE_PATH):
        add_autoload_singleton(MessageBus.AUTOLOAD_NAME, "res://addons/librarian/scripts/message_bus.gd")
