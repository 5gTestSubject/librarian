# Librarian

A trusty librarian to manage and validate structured, interconnected data.

> [!WARNING]  
> Librarian is in early development! Breaking changes are still occurring frequently without announcement, especially when it comes to data persistence.
> 
> Librarian is currently not recommended for project use. To protect your project data, use source control on any project with Librarian integrated.

Somewhere between a spreadsheet and a SQL database, Librarian is a Godot 4 editor plugin for managing typed, tabular game data. It guides the developer to various inconsistencies in game data at development time based on user-defined, declarative tests for data compliance.

## Contents

- [Key Features](#key-features)
- [Getting Started](#getting-started)
- [License](#license)

## Key Features

> [!NOTE]  
> This section describes the goal state for a 1.0 release of Librarian, not the current state of the project.

### Familiar Spreadsheets

Librarian is functionally a domain-specific spreadsheet program. It even saves much of the data it manages in CSV format! Edit your data as you would in any common spreadsheet program, one table to a type and one column per field.

### Strictly Typed Fields

A string is not a texture and no sane code will turn an arbitrary `Hello, world!` into the path to your item sprite. Unlike many spreadsheet programs, Librarian strictly enforces data types for all columns and ensures they always contain a valid value.

Librarian supports flags, numbers, text, textures, themes, color palettes, general scenes and resources, and more as field types.

### Declarative Data Tests *(Coming Soon)*

Need to ensure unique IDs? Not sure if you have every character portrait for your dialogue system? Does every weapon in your item system need a corresponding weapon stats definition? Librarian has you covered.

Write tests which describe your data declaratively using GDScript and Librarian will validate every entry for compliance. Tests can run at the scope of individual rows, a whole table, or even across multiple tables.

Test compliance is not a strict requirement. It can be hard to keep up with all your rules while rapidly prototyping. You can still save non-compliant datasheets and trust your game code to handle missing or inconsistent data as needed. Librarian will not stop you, it will only alert you.

### Global Tagging System *(Coming Soon)*

Every spreadsheet has a `Tags` column. Tags are defined with a unique name at the project level and can be placed on any row in any spreadsheet. In addition to being available to your game at runtime, tags are primarily useful for data tests.

## Getting Started

> [!TIP]  
> This plugin uses a tab bar at the top of its main screen component, which may be confusing when beneath the editor's tab bar of open scenes.
>
> It is recommended to use [Scene Selector](https://github.com/jbreitweiser/scene_selector) (or some other plugin that can disable the editor's scene tabs) in addition to Librarian. Scene Selector will not turn these tabs off by default for the Librarian main screen, but this can be configured in its settings.

This plugin is not yet on the Godot Asset Library. Download this repository and copy `addons/librarian` to your Godot 4 project's `addons` directory.

Alternatively, this repository contains a sample library to demonstrate existing functionality. To use it, download this repository and open it as a project in Godot 4.

Go to project settings and enable the plugin. This will create a new main screen "Librarian." Additionally, it will create two docks "Library" and "Table." By default, they are docked alongside the "FileSystem" and "Scene" docks, respectively.

"Library" is an overview of the contents of your library. By default your library is contained in `res://data/library`, but this can be changed in project settings. Here you can access spreadsheets, global tags, and data tests.

"Table" contains information about whatever spreadsheet is currently active in the main screen. It is where you will edit the structure of the table as well as manage its data tests.

## License

This project licensed under the MIT License.

[Directory Watcher](https://github.com/KoBeWi/Godot-Directory-Watcher) by [Tomasz Chabora](https://github.com/KoBeWi) used under MIT License.
