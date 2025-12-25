
<img width="167" height="161" alt="Paletter_icon" src="https://github.com/user-attachments/assets/c2ab840d-e801-43b6-80b1-f6f9a6908bd8" />



# Paletter
#### Godot 4.5+ Plugin to import and export *.gpl and *.txt palette files.

This plugin will import a *.gpl (GIMP) or *.txt (paint.net) file and load it into a ColorPalette resource object of your choice. You can then open a standard Godot ColorPicker and load the ColorPalette object into the swatch panel. If you modify the swatch colors and save them as a new ColorPalette object then this plugin can export it to a *.gpl or *.txt file as well.

------------


##### Install
Open the AssetLib tab in the editor and search for Paletter. Alternatively, download a zip of this repo and place the **paletter** folder into you project's **addons** folder (create **addons** if it does not exist).

Godot will automatically activate the addon if you downloaded from the AssetLib. Otherwise you'll need to go to `Project Settings->Plugins` and activate it.


##### Use
The Paletter panel will initiate on the right hand side of the editor. Select a source palette file, a ColorPalette resource file, and then press Load to import and load the colors. The ColorPalette resorce can then be loaded to a ColorPicker swatch for use in your project. To save a new swatch, Save or SaveAs the swatch (as a ColorPalette resource), select the resource in the plugin, then export as required.

<img width="238" height="708" alt="Paletter_Panel" src="https://github.com/user-attachments/assets/3fbd7c9e-6246-46e8-8b58-2bcd13ed9a35" />
