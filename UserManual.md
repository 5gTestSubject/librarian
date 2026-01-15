## Spreadsheet Navigation

Spreadsheets are designed to be navigable solely through the keyboard similar to popular spreadsheet programs.
Inputs detailed below.

| Action | Input |
| ------ | -------- |
| Move one cell in a direction | Arrow key |
| Move one cell forward | `Tab` |
| Move one cell backward | `Shift` + `Tab` |
| Move to edge of spreadsheet in a direction | `Ctrl` + arrow key
| Move to beginning of row | `Home` |
| Move to beginning of sheet | `Ctrl` + `Home` |
| Move to end of row | `End` |
| Move to end of sheet | `Ctrl` + `End` |
| Exit spreadsheet focus | `Esc` |

### A note about Godot UI focus

Spreadsheet cells have their focus neighbors setup to be unable to leave the spreadsheet.
E.g. pressing left arrow key in the left-most column will keep focus in the same cell.
To move focus out of the spreadsheet into the rest of the editor UI, press `Esc`.
This will move focus to the current tab in the tab bar of open spreadsheets.
