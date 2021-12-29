# Lönn Scripts
A plugin for [Lönn](https://github.com/CelestialCartographers/Loenn) adding easy to use, yet powerful scripting features.

## WARNING

Scripts are not sandboxed in any way, shape or form. Scripts included with the mod are safe, but if you receive a script form someone, make sure that you understand what the script does before running it!

## Features
* Most scripts can be reverted using CTRL+Z
* Scripts can accept parameters received from a GUI the same way an entity would
* Scripts have their own tool tab, making it possible to save scripts for later use
* Scripts can be ran on either a single room, or in every room in the map at once
* Allows the user to add new scripts themselves
* Allows other mods to register new scripts

## Usage
1. Install the Lönn Scripts mod the same way you would install an [Everest](https://github.com/EverestAPI/Everest) mod.
2. Restart Lönn if you had it open.
3. A new `scripts` tool should appear in the Tool List. Select it.
4. Make a backup of your map's .bin file, just in case
5. Select any script you want, then click on any room the same way as you would place an entity.
  * If the script supports parameters, a new window will open. Choose the parameters you want, then click on `Run Script`.
  * Otherwise, the script will run immediately.
6. If the script didn't work like you wanted, try using CTRL+Z. Most scripts support this. If not, revert to the backup you just made.

## Code Examples

Check the `Loenn/scripts` folder in the repo for examples of scripts.