# Godot 4 Palette Tools

This is a small addon that allows for easy color palette integration in Godot 4. Quickly Create/Download palettes. Load/Save for use any time. Comes with the ability to quickly switch the editor's color-picker swatches as well as a custom color picker that can switch between palettes on demand. Download option currently supports Lospec palettes.

## Setup

**Errors will appear in the output console when you first add the plugin to a project, and you must restart the project before it will work!!!** Many Godot plugins do this and they shouldn't appear on future loads, and are safe to ignore. If for some reason it's not working after you restart the project, open an issue in the [repo](https://github.com/RancidMilkGames/GodotPaletteTools).

Copy either the entire "addons" folder or the folder inside the "addons" folder from this project into your own. If you don't have an addons folder, make one in the project root.

**Addon will appear in the same dock as the inspector/node/history tabs**(Usually on the right side of the screen). You may have to scroll to see it.

## USE

* **Custom Palette Picker**: Replaces the default color picker with an extended one that can switch between palettes [Default: off]
* **Saved Palettes**: List of previously saved palettes. To load or delete a palette, select it in the list and then press the corresponding button.
* **Get from Lospec**: Either enter a Lospec palette URL or browse through popular palettes. The plugin will automatically keep track of the name of the palette and it's author for referencing or crediting.
* **Palette Preview**: Preview/editor for palettes. Click the plus sign to add a color to the palette. Existing colors can be edited by clicking on them, or removed with the red close button in the top right corner of the button. The save palette button will store the palette. If you have an eligible palette, an option will appear that allows you to save it to the editor's swatches which can be accessed from both the default color picker and the extended one.

## Tips

* You can copy the "res://addons/PaletteTools/color_presets.cfg" file to move saved palettes/settings between projects

## Future

I consider this plugin mostly done, but still use it regularly, so if Godot has any braking changes that affect it, those will probably be addressed. It also might get the occasional new feature. Some current thoughts are:

- [ ] Theme integration of some sort
- [ ] The ability to mass convert one color in the project to another

## Notes

* Tested on Godot 4.2. If you'd like to run it on an earlier version of Godot 4, [this is a link](https://github.com/RancidMilkGames/GodotPaletteTools/tree/47c09b8d6e43a0acc0380a1344a4b2282f95d49b) to the last commit before the 4.2 changes.
* Custom Color picker won't work when editing resources. I'm not sure if this is possible to implement in Godot's current state.
