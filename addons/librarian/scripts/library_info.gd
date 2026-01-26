@tool
extends Node

const TagAccess := preload("res://addons/librarian/scripts/io/tag_access.gd")

const AUTOLOAD_NAME := "LibraryInfo"
const AUTOLOAD_NODE_PATH := ^"/root/LibraryInfo"

## Tag ID to tag.
@export var tags: Dictionary[StringName, LibraryTag]

func _ready() -> void:
    load_all()

func load_all() -> void:
    return load_tags()

func load_tags() -> void:
    tags = TagAccess.load_tags()

func save_all() -> bool:
    return save_tags()

func save_tags() -> bool:
    var list = tags.values()
    list.sort_custom(func(left: LibraryTag, right: LibraryTag): return left.name < right.name)
    return TagAccess.save_tags(list)
