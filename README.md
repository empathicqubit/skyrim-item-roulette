# skyrim-item-roulette

Roulettes items

## Notes

* NIF export from Blender is perfectly fine if you're working from scratch.
Skyrim doesn't seem to care that the models are an old format.
* It should go without saying that if you change a model texture or any
resource other than the main plugin file, make sure you redeploy from Vortex
or you won't see the changes.
* Likewise, if you change the texture in GIMP, you must rebuild the textures
or you won't see them anywhere.
* If you include a texture it must be connected to the Color node of the Material
in the Shader node view, and the **node name** must be `Base`. The image path must
be the DDS in the /plugin folder. The NIF plugin is intelligent enough to relativize
the path when exporting.