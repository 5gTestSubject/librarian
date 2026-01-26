# Developer Docs

Conceptual documentation on what some things are, what they accomplish, and maybe even a little bit of why it's done that way.

## File Definitions

Writeups for the types of files created and managed by Librarian.

### `.ltcsv` &mdash; Librarian Table CSV

Plaintext contents of a spreadsheet.

The first line of the file contains a version string.

The second line of the file contains a complete JSON object describing the table. This object contains spreadsheet metadata and informs how to parse spreadsheet entries.

The rest of the file contains spreadsheet data in CSV format. The number of cells in each row is uniform, determined by the metadata at the top of the file.

A custom file extension is used to avoid conflicts with Godot's `.csv` importer, which will attempt to import it as a translation. This extension has the added benefit of being hidden in the editor's file explorer, directing users to go through the `Library` dock.

### `.ltags` &mdash; Librarian Tags

Plaintext tag definitions.

The first line of the file contains a version string.

The rest of the file contains tag entries in CSV format. The format uses the default `,` delimiter with standard `"` escapes (the default behavior of Godot's CSV parser).

#### Version `1.0`

Tag entries are defined by the following columns, in order:

- ID: Unique ID of the tag.
- Name: Display name of the tag.
- Description: Any supplemental text the user may choose to associate with the tag. This value may be left empty.
- Color: Optional color associated with the tag. This value may be left empty. Otherwise, it must be a valid hexadecimal color string (case insensitive hex values; 3, 4, 6, or 8 digits; optionally prefixed with `#`).
