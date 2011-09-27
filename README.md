Dynamic Texture Generator (Starling framework Extension)
========

This tool will convert any MovieClip containing Other MovieClips, Sprites or Graphics into a starling Texture Atlas, all in runtime. 
By using it, you won't have to statically create your spritesheets. Just take a regular MovieClip containing all the display objects you wish to put into your Altas, and convert everything from vectors to bitmap textures. 
This extension could save you a lot of time specially if you'll be coding mobile apps with the starling framework.

#### Features ####

* Dynamic creation of a Texture Altas from a MovieClip (flash.display.MovieClip) container that could act as a sprite sheet
* Filters made to the objects are captured
* Automatically detects the objects bounds so you don't necesarily have to set the registration points to TOP LEFT

#### Usage ####
	DynamicAtlas.fromMovieClipContainer(swf:flash.display.MovieClip):starling.textures.TextureAtlas

#### Steps ####
### Base Sprite sheet creation (Inside Flash IDE) ###
Create a new fla and make sure it is minimum flash 9 using as3.
Start creating movieclips that you want to be written to a sprite sheet. Be sure to avoid using actionscript, and if you have sub clips use graphics as opposed to movieclips so that they get picked up.
Drag all the movieclips you want rendered to the main stage and name them.
Export the swf.

You can also drag all the MovieClips inside another Clip and assign a class to it if you prefer not to load an external swf.

### TextureAtlas conversion ### 
Load the sprite sheet swf or create an instance of it as a MovieClip
Use the DynamicAtlas.fromMovieClipContainer() static method to convert your flash.display.MovieClip to a starling.textures.TextureAtlas.
	
This project began as a fork of the [Texture Atlas Generator](https://github.com/pixelrevision/texture_atlas_generator) by pixelrevision