# Developer Docs

Conceptual documentation on what some things are, what they accomplish, and maybe even a little bit of why it's done that way.

## File Definitions

Writeups for the types of files created and managed by Librarian.

### `.ltcsv` &mdash; Librarian Table CSV

Plaintext contents of a spreadsheet in CSV file format. This uses the default `,` delimiter with standard `"` escapes (the default behavior of Godot's CSV parser).

The first row of the table contains a single column. This column contains a JSON object describing the table, matching the type definition of `LibraryTableInfo`.

All following rows are the plain spreadsheet data in CSV format. The number of cells in each row is uniform, determined by the metadata of the first row.

A custom file extension is used to avoid conflicts with Godot's `.csv` importer, which will attempt to import it as a translation. This extension has the added benefit of being hidden in the editor's file explorer, directing users to go through the `Library` dock.

### `.ltags` &mdash; Librarian Tags

Plaintext tag definitions in CSV format.

The first row of the table contains a single column. This column contains a version string.

All following rows are tag data.

#### Version `1.0`

Tag data is defined by the following columns, in order:

- ID: UUID of the tag.
- Name: Display name of the tag.
- Description: Any supplemental text the user may choose to associate with the tag. This value may be left empty.
- Color: Optional color associated with the tag. This value may be left empty. Otherwise, it must be a valid hexadecimal color string (case insensitive hex values; 3, 4, 6, or 8 digits; optionally prefixed with `#`).
