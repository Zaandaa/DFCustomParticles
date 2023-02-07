# About

Create particles with any built-in Dustforce sprites and custom embeds. Custom images also support animation. Include **CustomParticles.as** in your map scripts then create a zScriptTrigger to make a Spawn object.

This project includes an example level **CPDemo** with the example sprites. Enemy images are from _Jels_ by eponn.

## Setup

Place **CPEmbed.as** and **CustomParticles.as** in your **script_src** directory.

If using built-in sprites, see [C's sprite reference](https://github.com/cmann1/PropUtils/tree/master/files/sprite_reference) to find `sprite_name` data.

If using embeds, edit **CPEmbed.as** as follows to match your sprites in your embed_src/sprites folder:

1. Add file path strings.
2. Add sprite names to `get_build_list()` array.
3. Include and specify all arguments in the `get_info()` dictionary.
4. After editing **CPEmbed.as**, add **CustomParticles.as** to your level scripts.

If not using embeds, rename **CPEmbedEmpty.as** to **CPEmbed.as**.

See **CPEmbed.as** for further comments and examples.
