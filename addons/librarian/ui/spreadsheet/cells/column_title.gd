@tool
extends PanelContainer

@export var cell_value: String = "":
    get: return $Label.text
    set(value): $Label.text = value
