# Godot 4 Palette Tools

This is a small addon that allows for easy color palette integration in Godot 4. Quickly Create/Download palettes. Load/Save for use any time. Comes with the ability to quickly switch the editor's color-picker swatches as well as a custom color picker that can switch between palettes on demand. Download option currently supports Lospec palettes.

## Setup

### Install Methods

#### Recommended:

Open the *AssetLib* tab in the editor and search for Palette Tools.

#### Manual Method:

From either the [project repo](https://github.com/RancidMilkGames/GodotPaletteTools) or [asset library website](https://godotengine.org/asset-library/asset) copy the "PaletteTools" folder to your project's "addons" folder. If this is your first time using a Godot plugin/addon, and you don't have an addons folder, make a folder named "addons" in the root of your project.

### Activate

Godot will automatically activate the addon if you used the previously mentioned recommended method. If done manually, go to `Project Settings->Plugins` to activate it.

<table>
  <thead>
    <tr>
      <td align="center">
        :warning: Notice
      </td>
    </tr>
  </thead>

  <tbody>
    <tr>
      <td>
        <ul>
          <li>Plugin will not be immediately noticeable. It will appear in the right-side dock with Inspector/Node/History. You may need to either expand the dock or use the arrows to access it.</li>
        </ul>
      </td>
    </tr>
  </tbody>
</table>

## USE

* **Custom Palette Picker**: Replaces the default color picker with an extended one that can switch between palettes. For special use cases and not thoroughly tested so by default it's set to off.
* **Saved Palettes**: List of previously saved palettes. To load or delete a palette, select it in the list and then press the corresponding button.
* **Get from Lospec**: Either enter a Lospec palette URL or browse through popular palettes. The plugin will automatically keep track of the palette name, and it's author for referencing or crediting.
* **Palette Preview**: Preview/editor for palettes. Click the plus sign to add a color to the palette. Existing colors can be edited by clicking on them, or removed with the red close button in the top right corner of the button. The save palette button will store the palette.
* **Replace Editor Swatches**: If you have an eligible palette, an option will appear that allows you to save it to the editor's swatches, which can be accessed from both the default color picker and the extended one.

## Tips

* You can copy the "res://addons/PaletteTools/color_presets.cfg" file to move saved palettes/settings between projects

## Future

I consider this plugin mostly done, but still use it regularly, so if Godot has any breaking changes that affect it, those will probably be addressed. It also might get the occasional new feature. Some current thoughts are:

- [ ] Theme integration of some sort
- [ ] The ability to mass convert one color in the project to another

## Notes

* Tested on Godot 4.2. If you'd like to run it on an earlier version of Godot 4, [this is a link](https://github.com/RancidMilkGames/GodotPaletteTools/tree/47c09b8d6e43a0acc0380a1344a4b2282f95d49b) to the last commit before the 4.2 changes.
* Custom Color picker won't work when editing resources. I'm not sure if this is possible to implement in Godot's current state.
